//
//  ChannelList.swift
//  Swiftcord
//
//  Created by Vincent on 4/12/22.
//

import SwiftUI

struct ChannelList: View {
    @Binding var channels: [Channel]
    @Binding var selCh: Channel?
    @Binding var guild: Guild?
    
    let chIcons = [
        ChannelType.voice: "speaker.wave.2.fill",
        .news: "megaphone.fill",
    ]
    
    var body: some View {
        List {
            ForEach(
                channels
                    .sorted(by: { c1, c2 in
                        if c1.type == .category || c2.type == .category { return c2.type == .category }
                        if c1.position != nil && c2.position != nil { return c2.position! > c1.position! }
                        return true
                    }),
                id: \.id
            ) { ch in
                if ch.type == .category {
                    Section(header: Text(ch.name?.uppercased() ?? "")) {
                        ForEach(
                            channels
                                .filter { $0.parent_id == ch.id }
                                .sorted(by: { c1, c2 in
                                    if c1.type == .voice, c2.type != .voice { return false }
                                    if c1.type != .voice, c2.type == .voice { return true }
                                    if c1.position != nil, c2.position != nil {
                                        return c2.position! > c1.position!
                                    } else { return c2.id > c1.id }
                                }),
                            id: \.id
                        ) { channel in
                            Button {
                                selCh = channel
                            } label: {
                                Label(
                                    channel.name ?? "",
                                    systemImage: (guild?.rules_channel_id != nil && guild?.rules_channel_id! == channel.id) ? "newspaper.fill" : (chIcons[channel.type] ?? "number")
                                ).frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.borderedProminent)
                            .accentColor(Color.gray)
                        }
                    }
                }
                else if ch.parent_id == nil {
                    Button {
                        
                    } label: {
                        Label(
                            ch.name ?? "",
                            systemImage: (guild?.rules_channel_id != nil && guild?.rules_channel_id! == ch.id) ? "newspaper.fill" : (chIcons[ch.type] ?? "number")
                        )
                    }
                    .accentColor(Color.gray)
                }
            }
        }
        .frame(minWidth: 240, maxHeight: .infinity)
    }
}
