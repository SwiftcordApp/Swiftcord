//
//  ServerView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import DiscordKit
import DiscordKitCore

class ServerContext: ObservableObject {
    @Published public var channel: Channel?
    @Published public var guild: Guild?
    @Published public var typingStarted: [Snowflake: [TypingStart]] = [:]
	@Published public var roles: [Role] = []
}

struct ServerView: View {
	let guild: Guild?
    @State private var evtID: EventDispatch.HandlerIdentifier?
    @State private var mediaCenterOpen: Bool = false

    @EnvironmentObject var state: UIState
    @EnvironmentObject var gateway: DiscordGateway
    @EnvironmentObject var audioManager: AudioCenterManager

	@StateObject var serverCtx: ServerContext

	private func loadChannels() {
		guard state.loadingState != .initial else { return } // Ensure gateway is connected before loading anything
		guard let channels = serverCtx.guild?.channels?.discordSorted()
		else { return }

		if let lastChannel = UserDefaults.standard.string(forKey: "lastCh.\(serverCtx.guild!.id)"),
           let lastChObj = channels.first(where: { $0.id == lastChannel }) { // swiftlint:disable:this indentation_width
            serverCtx.channel = lastChObj
            return
        }
        let selectableChs = channels.filter { $0.type != .category }
		serverCtx.channel = selectableChs.first

        // Prevent deadlocking if there are no DMs/channels
		if serverCtx.channel == nil { state.loadingState = .messageLoad }
    }

	private func bootstrapGuild(with guild: Guild) {
		serverCtx.guild = guild
		serverCtx.roles = []
		loadChannels()
		// Sending malformed IDs causes an instant Gateway session termination
		guard !guild.isDMChannel else {
			AnalyticsWrapper.event(type: .DMListViewed, properties: [
				"channel_id": serverCtx.channel?.id ?? "",
				"channel_type": serverCtx.channel?.type.rawValue ?? 1
			])
			return
		}

		AnalyticsWrapper.event(type: .guildViewed, properties: [
			"guild_id": guild.id,
			"guild_is_vip": guild.premium_tier != PremiumLevel.none,
			"guild_num_channels": guild.channels?.count ?? 0
		])

		// Subscribe to typing events
		gateway.subscribeGuildEvents(id: guild.id)
		serverCtx.roles = guild.roles.compactMap { role in try? role.result.get() }
		// Retrieve guild roles to update context
		/*Task {
			guard let newRoles = await restAPI.getGuildRoles(id: guild.id) else { return }
			print(newRoles)
			serverCtx.roles = newRoles
		}*/
	}

    private func toggleSidebar() {
		NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }

    var body: some View {
        NavigationView {
            // MARK: Channel List
            VStack(spacing: 0) {
				if let guild = guild {
					ChannelList(channels: guild.name == "DMs" ? gateway.cache.dms : guild.channels!, selCh: $serverCtx.channel)
						.toolbar {
							ToolbarItem {
								Text(guild.name == "DMs" ? "dm" : "\(guild.name)")
									.font(.title3)
									.fontWeight(.semibold)
									.frame(maxWidth: 208) // Largest width before disappearing
							}
						}
						.onChange(of: serverCtx.channel?.id) { newID in
							guard let newID = newID else { return }
							UserDefaults.standard.setValue(
								newID,
								forKey: "lastCh.\(serverCtx.guild!.id)"
							)
						}
				} else {
					ZStack {}
						.frame(minWidth: 240, maxHeight: .infinity)
				}

                if !gateway.connected || !gateway.reachable {
                    Label(
                        gateway.reachable
                        ? "Reconnecting..."
                        : "No network connectivity",
                        systemImage: gateway.reachable ? "arrow.clockwise" : "bolt.horizontal.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .background(gateway.reachable ? .orange : .red)
                    .animation(.easeIn, value: gateway.reachable)
                }
				if let user = gateway.cache.user { CurrentUserFooter(user: user) }
            }

            // MARK: Message History
			if serverCtx.channel != nil {
				MessagesView()
			} else {
				VStack(spacing: 24) {
					Image(serverCtx.guild?.id == "@me" ? "NoDMs" : "NoGuildChannels")
					if serverCtx.guild?.id == "@me" {
						Text("dm.noChannels.body").opacity(0.75)
					} else {
						Text("server.noChannels.header").font(.headline).textCase(.uppercase)
						Text("server.noChannels.body")
							.padding(.top, -16)
							.multilineTextAlignment(.center)
					}
				}
				.padding()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(.gray.opacity(0.15))
			}
        }
		.environmentObject(serverCtx)
        .navigationTitle("")
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                HStack {
					Button {
						NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
					} label: {
                        Image(
                            systemName: serverCtx.channel?.type == .dm
                            ? "at"
                            : (serverCtx.channel?.type == .groupDM ? "person.2.fill" : "number")
						).foregroundColor(.primary.opacity(0.8))
					}
					Text(serverCtx.channel?.label(gateway.cache.users) ?? "No Channel")
						.font(.title2)
                }
            }
            ToolbarItem(placement: .navigation) {
                Button(action: { mediaCenterOpen = true }, label: { Image(systemName: "play.circle") })
                    .popover(isPresented: $mediaCenterOpen) { MediaControllerView() }
            }
        }
        .onChange(of: audioManager.queue.count) { [oldCount = audioManager.queue.count] count in
            if count > oldCount { mediaCenterOpen = true }
        }
        .onChange(of: guild) { newGuild in
			guard let newGuild = newGuild else { return }
			bootstrapGuild(with: newGuild)
		}
        .onChange(of: state.loadingState) { newState in if newState == .gatewayConn { loadChannels() }}
        .onAppear {
			if let guild = guild { bootstrapGuild(with: guild) }

            evtID = gateway.onEvent.addHandler { evt in
                switch evt {
                /*case .channelUpdate(let updatedCh):
                   if let chPos = channels.firstIndex(where: { ch in ch == updatedCh }) {
                        // Crappy workaround for channel list to update
                        var chs = channels
                        chs[chPos] = updatedCh
                        channels = []
                        channels = chs
                    }*/
                    // For some reason, updating one element doesnt update the UI
                    // loadChannels()*/
                case .typingStart(let typingData):
                    guard typingData.user_id != gateway.cache.user!.id else { break }

                    // Remove existing typing items, if present (prevent duplicates)
                    serverCtx.typingStarted[typingData.channel_id]?.removeAll {
                        $0.user_id == typingData.user_id
                    }

                    if serverCtx.typingStarted[typingData.channel_id] == nil {
                        serverCtx.typingStarted[typingData.channel_id] = []
                    }
                    serverCtx.typingStarted[typingData.channel_id]!.append(typingData)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                        serverCtx.typingStarted[typingData.channel_id]?.removeAll {
                            $0.user_id == typingData.user_id
                            && $0.timestamp == typingData.timestamp
                        }
                    }
                default: break
                }
            }
        }
        .onDisappear {
            if let evtID = evtID { _ = gateway.onEvent.removeHandler(handler: evtID) }
        }
    }
}
