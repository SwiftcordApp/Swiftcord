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

struct CustomHorizontalDivider: View {
    var body: some View {
        Rectangle().fill(Color(NSColor.separatorColor))
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    /*@FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MessageItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<MessageItem>*/

    @State private var sheetOpen = false
    @State private var loadingGuildID: Snowflake?
	@State private var presentingOnboarding = false
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

                    CustomHorizontalDivider().frame(width: 32, height: 1)

					ForEach(
						(gateway.cache.guilds.values.filter({
							!(gateway.cache.userSettings?.guild_positions ?? []).contains($0.id)
						}).sorted(by: { lhs, rhs in lhs.joined_at! > rhs.joined_at! }))
						+ (gateway.cache.userSettings?.guild_positions ?? [])
							.compactMap({ gateway.cache.guilds[$0] })
					) { guild in
                        ServerButton(
							selected: state.selectedGuildID == guild.id || loadingGuildID == guild.id,
                            name: guild.name,
                            serverIconURL: guild.icon != nil ? "\(GatewayConfig.default.cdnURL)icons/\(guild.id)/\(guild.icon!).webp?size=240" : nil,
                            isLoading: loadingGuildID == guild.id,
							onSelect: { state.selectedGuildID = guild.id }
                        )
                    }

                    ServerButton(
                        selected: false,
                        name: "Add a Server",
                        systemIconName: "plus",
                        bgColor: .green,
                        noIndicator: true,
                        onSelect: {}
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
							.padding(.top, -13),
						alignment: .trailing
					)
					.overlay(.black.opacity(0.2))
			)
            .frame(maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .top) {
                List {}
					.listStyle(.sidebar)
					.frame(width: 72, height: 0)
                    .offset(y: -13)
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
