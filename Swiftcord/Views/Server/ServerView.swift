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
	let guild: Guild?
    @State private var evtID: EventDispatch.HandlerIdentifier? = nil
    @State private var mediaCenterOpen: Bool = false
    
    @EnvironmentObject var state: UIState
    @EnvironmentObject var gateway: DiscordGateway
    @EnvironmentObject var audioManager: AudioCenterManager
    
    @StateObject private var serverCtx = ServerContext()
	
	private func loadChannels() {
		guard let channels = serverCtx.guild?.channels
		else { return }
		
		if let lastChannel = UserDefaults.standard.string(forKey: "guildLastCh.\(serverCtx.guild!.id)"),
		   let lastChObj = channels.first(where: { $0.id == lastChannel }) {
			   serverCtx.channel = lastChObj
			   return
        }
        let selectableChs = channels.filter { $0.type != .category }
		serverCtx.channel = selectableChs.first
		
		if serverCtx.channel == nil { state.loadingState = .messageLoad }
		// Prevent deadlocking if there are no DMs/channels
    }
	
	private func bootstrapGuild(_ g: Guild) {
		serverCtx.guild = g
		loadChannels()
		// Sending malformed IDs causes an instant Gateway session termination
		guard !g.isDMChannel else { return }
		// Subscribe to typing events
		gateway.socket.send(
			op: .subscribeGuildEvents,
			data: SubscribeGuildEvts(guild_id: g.id, typing: true)
		)
	}
    
    private func toggleSidebar() {
        #if os(macOS)
		NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
				if let guild = guild {
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
					Text("No server selected")
						.frame(minWidth: 240, maxHeight: .infinity)
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
			} else {
				VStack(spacing: 24) {
					Image(serverCtx.guild?.id == "@me" ? "NoDMs" : "NoGuildChannels")
					if serverCtx.guild?.id == "@me" {
						Text("Wumpus is waiting on friends. You don't have to, though!").opacity(0.75)
					} else {
						Text("NO TEXT CHANNELS").font(.headline)
						Text("""
You find yourself in a strange place. \
You don't have access to any text channels or there are none in this server.
""").padding(.top, -16).multilineTextAlignment(.center)
					}
				}
				.padding()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(.gray.opacity(0.15))
			}
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                HStack {
					Image(
						systemName: serverCtx.channel?.type == .dm ? "at" :
							(serverCtx.channel?.type == .groupDM ? "person.2.fill" : "number")
					).font(.system(size: 18)).opacity(0.77).frame(width: 24, height: 24)
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
			guard let g = newGuild else { return }
			bootstrapGuild(g)
		}
        .onChange(of: state.loadingState) { s in if s == .gatewayConn { loadChannels() }}
        .onAppear {
			if let g = guild { bootstrapGuild(g) }
			
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
