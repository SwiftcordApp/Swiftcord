//
//  ContentView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import SwiftUI
import CoreData
import os
import DiscordKit
import DiscordKitCore
import DiscordKitCommon

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    /*@FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MessageItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<MessageItem>*/

	private static var insetOffset: CGFloat {
		// #available cannot be used in ternary statements (yet)
		if #available(macOS 13.0, *) { return 0 } else { return -13 }
	}
	private static var dividerOffset: CGFloat {
		// #available cannot be used in ternary statements (yet)
		if #available(macOS 13.0, *) { return -8 } else { return -13 }
	}

    @State private var loadingGuildID: Snowflake?
	@State private var presentingOnboarding = false
	@State private var presentingAddServer = false
	@State private var skipWhatsNew = false
	@State private var whatsNewMarkdown: String?

    @StateObject private var audioManager = AudioCenterManager()

    @EnvironmentObject var gateway: DiscordGateway
	@EnvironmentObject var restAPI: DiscordREST
    @EnvironmentObject var state: UIState

	@AppStorage("local.seenOnboarding") private var seenOnboarding = false
	@AppStorage("local.previousBuild") private var prevBuild: String?

    private let log = Logger(category: "ContentView")

	private func makeDMGuild() -> Guild {
		return Guild(id: "@me",
					 name: "DMs",
					 owner_id: "",
					 afk_timeout: 0,
					 verification_level: .none,
					 default_message_notifications: .all,
					 explicit_content_filter: .disabled,
					 roles: [], emojis: [], features: [],
					 mfa_level: .none,
					 system_channel_flags: 0,
					 channels: gateway.cache.dms,
					 premium_tier: .none,
					 preferred_locale: .englishUS,
					 nsfw_level: .default,
					 premium_progress_bar_enabled: false)
	}

	private func loadLastSelectedGuild() {
		if let lGID = UserDefaults.standard.string(forKey: "lastSelectedGuild"),
		   gateway.cache.guilds[lGID] != nil || lGID == "@me" {
			state.selectedGuildID = lGID
		} else { state.selectedGuildID = "@me" }
	}

    private var serverListItems: [ServerListItem] {
        let unsortedGuilds = gateway.cache.guilds.values.filter({ guild in
            !(gateway.cache.userSettings?.guild_folders?.contains(where: { folder in
                folder.guild_ids.contains(guild.id)
            }) ?? false)
        })
            .sorted(by: { lhs, rhs in lhs.joined_at! > rhs.joined_at! })
            .map({ ServerListItem.guild($0) })
        return unsortedGuilds + (gateway.cache.userSettings?.guild_folders ?? []).compactMap { folder -> ServerListItem? in
            if folder.guild_ids.count > 1 {
                let guilds = folder.guild_ids.compactMap {
                    gateway.cache.guilds[$0]
                }
                let name = folder.name ?? String(guilds.map { $0.name }.joined(separator: ", "))
                return .guildFolder(ServerFolder.GuildFolder(
                    name: name, guilds: guilds, color: folder.color.flatMap { Color(hex: $0) } ?? Color.accentColor
                ))
            } else {
                guard let guild = gateway.cache.guilds[folder.guild_ids.first ?? ""] else {
                    return nil
                }
                return .guild(guild)
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ServerButton(
						selected: state.selectedGuildID == "@me",
                        name: "Home",
                        assetIconName: "DiscordIcon",
						onSelect: { state.selectedGuildID = "@me" }
                    ).padding(.top, 4)

					HorizontalDividerView().frame(width: 32)

                    ForEach(self.serverListItems) { item in
                        switch item {
                        case .guild(let guild):
                            ServerButton(
                                selected: state.selectedGuildID == guild.id || loadingGuildID == guild.id,
                                name: guild.name,
                                serverIconURL: guild.icon != nil ? "\(GatewayConfig.default.cdnURL)icons/\(guild.id)/\(guild.icon!).webp?size=240" : nil,
                                isLoading: loadingGuildID == guild.id,
                                onSelect: { state.selectedGuildID = guild.id }
                            )
                        case .guildFolder(let folder):
                            ServerFolder(
                                folder: folder,
                                selectedGuildID: $state.selectedGuildID,
                                loadingGuildID: loadingGuildID
                            )
                        }
                    }

                    ServerButton(
                        selected: false,
                        name: "Add a Server",
                        systemIconName: "plus",
                        bgColor: .green,
                        noIndicator: true,
                        onSelect: { presentingAddServer = true }
					).padding(.bottom, 4)
                }
                .padding(.bottom, 8)
                .frame(width: 72)
            }
			.background(
				List {}
					.listStyle(.sidebar)
					.overlay(
						Rectangle()
							.frame(width: 1, alignment: .bottom)
							.foregroundColor(Color(nsColor: .separatorColor))
							.padding(.top, ContentView.dividerOffset),
						alignment: .trailing
					)
					.overlay(.black.opacity(0.2))
			)
            .frame(maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .top) {
                List {}
					.listStyle(.sidebar)
					.frame(width: 72, height: 0)
					.frame(maxHeight: 0)
					.offset(y: ContentView.insetOffset)
					.overlay(
						Rectangle()
							.frame(height: 1, alignment: .bottom)
							.foregroundColor(Color(nsColor: .separatorColor)),
						alignment: .top
					)
            }

			ServerView(
				guild: state.selectedGuildID == nil
				? nil
				: (state.selectedGuildID == "@me" ? makeDMGuild() : gateway.cache.guilds[state.selectedGuildID!]), serverCtx: state.serverCtx
			)
        }
        .environmentObject(audioManager)
		.onChange(of: state.selectedGuildID) { id in
            guard let id = id else { return }
			UserDefaults.standard.set(id.description, forKey: "lastSelectedGuild")
        }
        .onChange(of: state.loadingState, perform: { state in
			if state == .gatewayConn { loadLastSelectedGuild() }
			if state == .messageLoad,
			   !seenOnboarding || prevBuild != Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
				if !seenOnboarding { presentingOnboarding = true }
				Task {
					do {
						whatsNewMarkdown = try await GitHubAPI
							.getReleaseByTag(org: "SwiftcordApp", repo: "Swiftcord", tag: "v\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")")
							.body
					} catch {
						skipWhatsNew = true
					}
					presentingOnboarding = true
					print(whatsNewMarkdown ?? "")
				}
			}
        })
        .onAppear {
			if state.loadingState == .messageLoad { loadLastSelectedGuild() }

            _ = gateway.onAuthFailure.addHandler {
                state.attemptLogin = true
                state.loadingState = .initial
                log.debug("Attempting login")
            }
            _ = gateway.onEvent.addHandler { (evt, _) in
                switch evt {
                case .ready:
                    state.loadingState = .gatewayConn
                    fallthrough
                case .resumed:
                    gateway.send(op: .voiceStateUpdate, data: GatewayVoiceStateUpdate(
                        guild_id: nil,
                        channel_id: nil,
                        self_mute: state.selfMute,
                        self_deaf: state.selfDeaf,
                        self_video: false
                    ))
                default: break
                }
            }
			_ = gateway.socket?.onSessionInvalid.addHandler { state.loadingState = .initial }
        }
		.sheet(isPresented: $presentingOnboarding) {
			seenOnboarding = true
			prevBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
		} content: {
			OnboardingView(
				skipOnboarding: seenOnboarding,
				skipWhatsNew: skipWhatsNew,
				newMarkdown: $whatsNewMarkdown,
				presenting: $presentingOnboarding
			)
		}
		.sheet(isPresented: $presentingAddServer) {
			ServerJoinView(presented: $presentingAddServer)
		}
	}

    private enum ServerListItem: Identifiable {
        case guild(Guild), guildFolder(ServerFolder.GuildFolder)

        var id: String {
            switch self {
            case .guild(let guild):
                return guild.id
            case .guildFolder(let folder):
                return folder.id
            }
        }
    }

    /*private func addItem() {
        withAnimation {
            let newItem = MessageItem(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
	 You should not use this function in a shipping application, although it may be useful
	 during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
	 You should not use this function in a shipping application, although it may be useful
	 during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }*/
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
