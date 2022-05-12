//
//  ServerView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI

class ServerContext: ObservableObject {
    @Published public var channel: Channel? = nil
    @Published public var guild: Guild? = nil
    @Published public var typingStarted: [Snowflake: [TypingStart]] = [:]
}

struct ServerView: View {
    @Binding var guild: Guild?
    @State private var channels: [Channel] = []
    @State private var evtID: EventDispatch.HandlerIdentifier? = nil
    
    @EnvironmentObject var state: UIState
    @EnvironmentObject var gateway: DiscordGateway
    @StateObject private var serverCtx = ServerContext()
    
    private func loadChannels() {
        guard let g = guild else { return }
        channels = g.channels!
        if let lastChannel = UserDefaults.standard.string(forKey: "guildLastCh.\(g.id)") {
            if let lastChObj = channels.first(where: { p in
                p.id == lastChannel
            }) {
                serverCtx.channel = lastChObj
                return
            }
        }
        let selectableChs = channels.filter { $0.type != .category }
        if !selectableChs.isEmpty { serverCtx.channel = selectableChs[0] }
        return
    }
    
    private func toggleSidebar() {
        #if os(iOS)
        #else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if guild != nil {
                    ChannelList(channels: $channels, selCh: $serverCtx.channel, guild: $guild)
                }
                else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                        .frame(maxHeight: .infinity)
                }

                if !gateway.connected || !gateway.reachable {
                    HStack {
                        Image(systemName: gateway.reachable ? "arrow.clockwise" : "bolt.horizontal.fill")
                        Text(gateway.reachable ? "Reconnecting..." : "No network connectivity")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .background(gateway.reachable ? .orange : .red)
                }
                if gateway.cache.user != nil {
                    CurrentUserFooter(user: gateway.cache.user!)
                }
            }
            .toolbar {
                // FIXME: This doesn't appear in the toolbar for some reason
                ToolbarItemGroup {
                    Text(guild?.name ?? "Loading").font(.title3).fontWeight(.semibold)
                        .frame(minWidth: 0)
                }
                /*
                ToolbarItem {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }*/
            }
            
            ZStack {
                if serverCtx.channel != nil, guild != nil { MessagesView().environmentObject(serverCtx) }
                else {
                    ProgressView("Server Loading...")
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                        .frame(minWidth: 400, minHeight: 250, alignment: .center)
                }
            }
        }
        .onChange(of: guild) { _ in
            guard let guild = guild else { return }
            serverCtx.guild = guild
            loadChannels()
            // Sending malformed IDs causes an instant Gateway session termination
            guard guild.id != "@me" else { return }
            // Subscribe to typing events
            gateway.socket.send(
                op: .subscribeGuildEvents,
                data: SubscribeGuildEvts(guild_id: guild.id, typing: true)
            )
        }
        .onChange(of: state.loadingState, perform: { s in if s == .gatewayConn { loadChannels() } })
        .onAppear {
            evtID = gateway.onEvent.addHandler { (evt, d) in
                switch evt {
                case .channelUpdate:
                    guard let updatedCh = d as? Channel else { break }
                    if let chPos = channels.firstIndex(where: { ch in ch == updatedCh }) {
                        // Crappy workaround for channel list to update
                        var chs = channels
                        chs[chPos] = updatedCh
                        channels = []
                        channels = chs
                    }
                    // For some reason, updating one element doesnt update the UI
                    // loadChannels()
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

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        // ServerView()
        Text("TODO")
    }
}
