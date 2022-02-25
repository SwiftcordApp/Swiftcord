//
//  ServerView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI

struct ServerView: View {
    let guild: Guild
    @State private var channels: [Channel] = []
    @State private var selectedCh: String? = nil
    @State private var isLoading = true
    
    let chIcons = [
        ChannelType.voice: "speaker.wave.2.fill",
        .news: "newspaper.fill",
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(
                    channels.filter { $0.type == .category },
                    id: \.id
                ) { category in
                    Section(header: Text(category.name ?? "")) {
                        ForEach(
                            channels.filter { $0.parent_id == category.id },
                            id: \.id
                        ) { channel in
                            NavigationLink(
                                destination: MessagesView(
                                    channel: channel,
                                    guildID: guild.id
                                ).onAppear {
                                    UserDefaults.standard.setValue(channel.id, forKey: "guildLastCh.\(guild.id)")
                                },
                                tag: channel.id,
                                selection: $selectedCh
                            ) {
                                Label(
                                    channel.name ?? "",
                                    systemImage: chIcons[channel.type] ?? "number"
                                )
                            }
                            .accentColor(Color.gray)
                        }
                    }
                }
            }
            .frame(minWidth: 240)
            .toolbar {
                ToolbarItemGroup {
                    Text(guild.name).font(.title3).fontWeight(.semibold)
                        .frame(minWidth: 0)
                    Spacer()
                    Button(action: {}) {
                        Label("Server options", systemImage: "chevron.down")
                    }
                }
            }
            
            VStack {
                Spacer()
                if isLoading {
                    ProgressView("Loading channels...")
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                }
                else {
                    Text("There aren't any text channels in this server")
                }
                Spacer()
            }.frame(minWidth: 400, minHeight: 250)
        }
        .onAppear {
            Task {
                // print(await DiscordAPI.getDMs())
                guard let c = await DiscordAPI.getGuildChannels(id: guild.id) else { return }
                channels = c
                
                if let lastChannel = UserDefaults.standard.string(forKey: "guildLastCh.\(guild.id)"), c.contains(where: { p in
                    p.id == lastChannel
                }) {
                    selectedCh = lastChannel
                    return
                }
                let txtChs = c.filter({ $0.type == .text })
                if !txtChs.isEmpty {
                    selectedCh = txtChs[0].id
                }
            }
        }
    }
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        // ServerView()
        Text("TODO")
    }
}
