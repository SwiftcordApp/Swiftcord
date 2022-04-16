//
//  ServerView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI

// UserDefaults.standard.setValue(channel.id, forKey: "guildLastCh.\(guild!.id)")

struct ServerView: View {
    @Binding var guild: Guild?
    @State private var channels: [Channel] = []
    @State private var selectedCh: Channel? = nil
    @State private var isLoading = true
    @State private var evtID: EventDispatch.HandlerIdentifier? = nil
    
    @EnvironmentObject var state: UIState
    @EnvironmentObject var gateway: DiscordGateway
    
    private func loadChannels() {
        guard let g = guild else { return }
        channels = []
        Task {
            isLoading = true
            selectedCh = nil
            guard let c = g.id == "@me"
                    ? await DiscordAPI.getDMs()
                    : await DiscordAPI.getGuildChannels(id: g.id)
            else { return }
            channels = c.compactMap({ t in try? t.result.get() })
            isLoading = false
            if state.loadingState == .initialGuildLoad { state.loadingState = .channelLoad }
            
            if let lastChannel = UserDefaults.standard.string(forKey: "guildLastCh.\(g.id)") {
                if let lastChObj = channels.first(where: { p in
                    p.id == lastChannel
                }) {
                    selectedCh = lastChObj
                    return
                }
            }
            let txtChs = channels.filter({ $0.type == .text })
            if !txtChs.isEmpty { selectedCh = txtChs[0] }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if guild != nil {
                    ChannelList(channels: $channels, selCh: $selectedCh, guild: $guild)
                }
                else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                        .frame(maxHeight: .infinity)
                }

                if gateway.cache.user != nil {
                    CurrentUserFooter(user: gateway.cache.user!)
                }
            }
            .toolbar {
                ToolbarItemGroup {
                    if guild != nil {
                        Text(guild!.name).font(.title3).fontWeight(.semibold)
                            .frame(minWidth: 0)
                    }
                    Spacer()
                    Button(action: {}) {
                        Label("Server options", systemImage: "chevron.down")
                    }
                }
            }
            
            ZStack {
                if isLoading {
                    ProgressView("Loading channels...")
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                        .frame(minWidth: 400, minHeight: 250, alignment: .center)
                } else if selectedCh != nil, guild != nil {
                    MessagesView(channel: $selectedCh, guildID: guild!.id)
                }
            }
        }
        .onChange(of: guild) { _ in loadChannels() }
        .onChange(of: state.loadingState, perform: { s in
            if s == .initialGuildLoad && !isLoading {
                // Put everything back into their initial states
                loadChannels()
            }
        })
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
                    break
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
