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
    
    let chIcons = [
        ChannelType.voice: "speaker.wave.2.fill"
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
                            NavigationLink {
                                Text(String(describing: channel))
                            } label: {
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
            .frame(minWidth: 200)
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
                Text("Test")

            }
            .frame(minWidth: 300)
        }
        .onAppear {
            Task {
                guard let c = await DiscordAPI().getGuildChannels(id: guild.id) else { return }
                channels = c
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
