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

struct ContentView: View {
    @State private var loadingGuildID: Snowflake?
    @State private var selectedGuild: Guild?

    @State private var presentingOnboarding = false
    @State private var presentingAddServer = false
    @State private var skipWhatsNew = false
    @State private var whatsNewMarkdown: String?

    @StateObject private var audioManager = AudioCenterManager()

    @EnvironmentObject var gateway: DiscordGateway
    @EnvironmentObject var state: UIState
    @EnvironmentObject var accountsManager: AccountSwitcher

    @AppStorage("local.seenOnboarding") private var seenOnboarding = false
    @AppStorage("local.previousBuild") private var prevBuild: String?

    private let log = Logger(category: "ContentView")

    private func makeDMGuild() -> Guild {
        Guild(
            id: "@me",
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
            premium_progress_bar_enabled: false
        )
    }

    private func loadLastSelectedGuild() {
        if let lGID = UserDefaults.standard.string(forKey: "lastSelectedGuild"),
            gateway.cache.guilds[lGID] != nil || lGID == "@me" {
            state.selectedGuildID = lGID
        } else {
            state.selectedGuildID = "@me"
        }
    }

    private var serverListItems: [ServerListItem] {
        let unsortedGuilds = gateway.cache.guilds.values.filter { guild in
            !gateway.guildFolders.contains { folder in
                folder.guild_ids.contains(guild.id)
            }
        }
        .sorted { lhs, rhs in lhs.joined_at! > rhs.joined_at! }
        .map { ServerListItem.guild($0) }
        return unsortedGuilds + gateway.guildFolders.compactMap { folder -> ServerListItem? in
            if folder.id != nil {
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
            // MARK: Server List
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ServerButton(
                      selectedID: $state.selectedGuildID,
                      guildID: .constant("@me"),
                      name: .constant("Home"),
                      serverIconURL: .constant(nil),
                      systemIconName: .constant(nil),
                      assetIconName: .constant("DiscordIcon")
                    )
                    .padding(.top, 4)

                    HorizontalDividerView().frame(width: 32)

                    ForEach(self.serverListItems) { item in
                        switch item {
                          case .guild(let guild):
                              ServerButton(
                                selectedID: $state.selectedGuildID,
                                guildID: .constant(guild.id),
                                name: .constant(guild.name),
                                serverIconURL: .constant(guild.icon != nil ? "\(DiscordKitConfig.default.cdnURL)icons/\(guild.id)/\(guild.icon!).webp?size=240" : nil),
                                systemIconName: .constant(nil),
                                assetIconName: .constant(nil),
                                isLoading: loadingGuildID == guild.id
                              )
                              .tag(guild.id)
                          case .guildFolder(let folder):
                              ServerFolder(
                                folder: folder,
                                open: state.selectedGuildID == folder.id || loadingGuildID == folder.id,
                                selectedGuildID: $state.selectedGuildID,
                                loadingGuildID: loadingGuildID
                              )
                              .tag(folder.id)
                        }
                    }

                    ServerButton(
                        selectedID: $state.selectedGuildID,
                        guildID: .constant("+"),
                        name: .constant("Add a Server"),
                        serverIconURL: .constant(nil),
                        systemIconName: .constant("plus"),
                        assetIconName: .constant(nil),
                        bgColor: .green,
                        noIndicator: true
                    ).padding(.bottom, 4)
                }
                .padding(.bottom, 8)
                .frame(width: 72)
            }
            .background(
                List {}
                    .listStyle(.sidebar)
                    .overlay(Color(nsColor: NSColor.controlBackgroundColor).opacity(0.5))
            )
            .frame(maxHeight: .infinity, alignment: .top)

            ServerView(guild: $selectedGuild)
              .onAppear()
              {
                guard let id = state.selectedGuildID else { selectedGuild = nil; return }
                
                selectedGuild = (id == "@me") ? makeDMGuild() : gateway.cache.guilds[id]
              }
        }
        // Blur the area behind the toolbar so the content doesn't show thru
        .safeAreaInset(edge: .top) {
            VStack {
                Divider().frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
        }
        .environmentObject(audioManager)
        .onChange(of: state.selectedGuildID) { id in
            guard let id = id else { return }
            UserDefaults.standard.set(id.description, forKey: "lastSelectedGuild")
            selectedGuild = (id == "@me") ? makeDMGuild() : gateway.cache.guilds[id]
        }
        .onChange(of: state.loadingState) { state in
            if state == .gatewayConn { loadLastSelectedGuild() }
            if state == .messageLoad,
               !seenOnboarding || prevBuild != Bundle.main.infoDictionary?["CFBundleVersion"] as? String { // swiftlint:disable:this indentation_width
                // If the user hasn't seen the onboarding (first page), present onboarding immediately
                if !seenOnboarding { presentingOnboarding = true }
                Task {
                    do {
                        whatsNewMarkdown = try await GitHubAPI
                            .getReleaseByTag(org: "SwiftcordApp", repo: "Swiftcord", tag: "v\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")")
                            .body
                    } catch {
                        skipWhatsNew = true
                        return
                    }
                    // If the user has already seen the onboarding, present the onboarding sheet only after loading the changelog
                    presentingOnboarding = true
                }
            }
        }
        .onAppear {
            if state.loadingState == .messageLoad { loadLastSelectedGuild() }

            _ = gateway.onEvent.addHandler { evt in
                switch evt {
                case .userReady(let payload):
                    state.loadingState = .gatewayConn
                    accountsManager.onSignedIn(with: payload.user)
                    fallthrough
                case .resumed:
                    gateway.send(.voiceStateUpdate, data: GatewayVoiceStateUpdate(
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
                skipWhatsNew: $skipWhatsNew,
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
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() // .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
