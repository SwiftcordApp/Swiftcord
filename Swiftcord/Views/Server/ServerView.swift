//
//  ServerView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI

struct ServerView: View {
    @Binding var guild: Guild?
    @State private var channels: [Channel] = []
    @State private var selectedCh: Channel? = nil
    @State private var evtID: EventDispatch.HandlerIdentifier? = nil
    
    @EnvironmentObject var state: UIState
    @EnvironmentObject var gateway: DiscordGateway
    
    private func loadChannels() {
        guard let g = guild else { return }
        channels = g.channels!
        if let lastChannel = UserDefaults.standard.string(forKey: "guildLastCh.\(g.id)") {
            if let lastChObj = channels.first(where: { p in
                p.id == lastChannel
            }) {
                selectedCh = lastChObj
                return
            }
        }
        let selectableChs = channels.filter { $0.type != .category }
        if !selectableChs.isEmpty { selectedCh = selectableChs[0] }
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
                if selectedCh != nil, guild != nil {
                    MessagesView(channel: $selectedCh, guildID: guild!.id)
                } else {
                    ProgressView("Server Loading...")
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                        .frame(minWidth: 400, minHeight: 250, alignment: .center)
                }
            }
        }
        .onChange(of: guild) { _ in loadChannels() }
        .onChange(of: state.loadingState, perform: { s in
            if s == .gatewayConn {
                print("initial guild load")
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
