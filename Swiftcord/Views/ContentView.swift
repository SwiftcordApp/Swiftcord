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

    private func makeDMGuild() -> PreloadedGuild {
        PreloadedGuild(
            channels: gateway.cache.dms,
            properties: Guild(
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
        .sorted { lhs, rhs in lhs.joined_at > rhs.joined_at }
        .map { ServerListItem.guild($0) }
        return unsortedGuilds + gateway.guildFolders.compactMap { folder -> ServerListItem? in
            if folder.id != nil {
                let guilds = folder.guild_ids.compactMap {
                    gateway.cache.guilds[$0]
                }
                let name = folder.name ?? String(guilds.map { $0.properties.name }.joined(separator: ", "))
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
                        selected: state.selectedGuildID == "@me",
                        name: "Home",
                        assetIconName: "DiscordIcon"
                    ) {
                        state.selectedGuildID = "@me"
                    }
                    .padding(.top, 4)

                    HorizontalDividerView().frame(width: 32)

                    ForEach(self.serverListItems) { item in
                        switch item {
                        case .guild(let guild):
                            ServerButton(
                                selected: state.selectedGuildID == guild.id || loadingGuildID == guild.id,
                                name: guild.properties.name,
                                serverIconURL: guild.properties.iconURL(),
                                isLoading: loadingGuildID == guild.id
                            ) {
                                state.selectedGuildID = guild.id
                            }
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
                        noIndicator: true
                    ) {
                        presentingAddServer = true
                    }.padding(.bottom, 4)
                }
                .padding(.bottom, 8)
                .frame(width: 72)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(VisualEffect()
                .overlay(Color(nsColor: NSColor.controlBackgroundColor).opacity(0.5))
            )

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
        case guild(PreloadedGuild), guildFolder(ServerFolder.GuildFolder)

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
