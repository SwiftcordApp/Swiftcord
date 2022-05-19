//
//  ServerView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import DiscordKit

class ServerContext: ObservableObject {
    @Published public var channel: Channel? = nil
    @Published public var guild: Guild? = nil
    @Published public var typingStarted: [Snowflake: [TypingStart]] = [:]
}

struct ServerView: View {
	let guildID: Snowflake?
    @State private var evtID: EventDispatch.HandlerIdentifier? = nil
    @State private var mediaCenterOpen: Bool = false
    
    @EnvironmentObject var state: UIState
    @EnvironmentObject var gateway: DiscordGateway
    @EnvironmentObject var audioManager: AudioCenterManager
    
    @StateObject private var serverCtx = ServerContext()
    
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
	
	private func loadChannels(_ overrideGuildID: Snowflake? = nil) {
		guard let guildID = overrideGuildID ?? guildID,
			  let channels = serverCtx.guild?.channels
		else {
			print("what the")
			return }
		
        if let lastChannel = UserDefaults.standard.string(forKey: "guildLastCh.\(guildID)"),
		   let lastChObj = channels.first(where: { $0.id == lastChannel }) {
			   serverCtx.channel = lastChObj
			   return
        }
        let selectableChs = channels.filter { $0.type != .category }
		serverCtx.channel = selectableChs.first
		
		if serverCtx.channel == nil {
			state.loadingState = .messageLoad
		}
		// Prevent deadlocking if there are no DMs/channels
    }
	
	private func guildChange(id: Snowflake?) {
	}
    
    private func toggleSidebar() {
        #if os(macOS)
		NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
				if let guild = serverCtx.guild {
					ChannelList(channels: guild.channels!, selCh: $serverCtx.channel, guild: guild)
						.toolbar {
							ToolbarItem {
								Text(guild.name)
									.font(.title3)
									.fontWeight(.semibold)
									.frame(maxWidth: 208) // Largest width before disappearing
							}
						}
				} else {
					Text("Guild loading")
						.frame(maxHeight: .infinity)
				}
				

                if !gateway.connected || !gateway.reachable {
					Label(gateway.reachable
						  ? "Reconnecting..."
						  : "No network connectivity",
						  systemImage: gateway.reachable ? "arrow.clockwise" : "bolt.horizontal.fill")
						.frame(maxWidth: .infinity)
						.padding(.vertical, 4)
						.background(gateway.reachable ? .orange : .red)
                }
				if let user = gateway.cache.user { CurrentUserFooter(user: user) }
            }
            
			if serverCtx.channel != nil {
				MessagesView()
					.environmentObject(serverCtx)
			} else if serverCtx.guild?.channels?.isEmpty ?? true, let g = serverCtx.guild {
				VStack(spacing: 24) {
					Image("NoChannelPlaceholder")
					Text(g.id == "@me"
						 ? "Wumpus is waiting on friends. You don't have to, though!"
						 : "There are no channels in this server")
						.opacity(0.75)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(.gray.opacity(0.15))
			} else {
				ProgressView("Server Loading...")
					.progressViewStyle(.circular)
					.controlSize(.large)
					.frame(minWidth: 400, minHeight: 250, alignment: .center)
			}
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                HStack {
                    Image(systemName: "number")
						.font(.system(size: 18)).opacity(0.77)
                    Text(serverCtx.channel?.name ?? "No Channel")
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
        .onChange(of: guildID) { id in
			serverCtx.guild = id == "@me"
				 ? makeDMGuild()
				 : gateway.cache.guilds?.first { g in g.id == id }
			 guard let guild = serverCtx.guild else { return }
			 loadChannels(id)
			 // Sending malformed IDs causes an instant Gateway session termination
			 guard !guild.isDMChannel else { return }
			 // Subscribe to typing events
			 gateway.socket.send(
				 op: .subscribeGuildEvents,
				 data: SubscribeGuildEvts(guild_id: guild.id, typing: true)
			 )
		}
        .onChange(of: state.loadingState) { s in if s == .gatewayConn { loadChannels() }}
        .onAppear {
            evtID = gateway.onEvent.addHandler { (evt, d) in
                switch evt {
                /*case .channelUpdate:
                    guard let updatedCh = d as? Channel else { break }
                    if let chPos = channels.firstIndex(where: { ch in ch == updatedCh }) {
                        // Crappy workaround for channel list to update
                        var chs = channels
                        chs[chPos] = updatedCh
                        channels = []
                        channels = chs
                    }
                    // For some reason, updating one element doesnt update the UI
                    // loadChannels()*/
                case .typingStart:
                    guard let typingData = d as? TypingStart,
                          typingData.user_id != gateway.cache.user!.id
                    else { break }
                    if serverCtx.typingStarted[typingData.channel_id] == nil {
                        serverCtx.typingStarted[typingData.channel_id] = []
                    }
                    serverCtx.typingStarted[typingData.channel_id]!.append(typingData)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                        serverCtx.typingStarted[typingData.channel_id]?.removeAll { t in
                            t.user_id == typingData.user_id
                            && t.timestamp == typingData.timestamp
                        }
                    }
                default: break
                }
            }
        }
        .onDisappear {
            if let evtID = evtID { let _ = gateway.onEvent.removeHandler(handler: evtID) }
        }
    }
}
