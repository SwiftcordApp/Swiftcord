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
                            ChannelButton(channel: channel, guild: guild, selectedCh: $selCh)
                                .listRowInsets(.init(top: 1, leading: 0, bottom: 1, trailing: 0))
                        }
                    }
                    .padding(.horizontal, 16)
                }
                else if ch.parent_id == nil { ChannelButton(channel: ch, guild: guild, selectedCh: $selCh)
                    .listRowInsets(.init(top: 1, leading: 16, bottom: 1, trailing: 16)) }
            }
        }
        .padding(.top)
        .padding(.horizontal, -14) // Horrible hack to work around List's clipping to bounds
        .listStyle(.sidebar)
        .frame(minWidth: 240, maxHeight: .infinity)
        // this overlay applies a border on the bottom edge of the view
        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color(nsColor: .separatorColor)), alignment: .top)
    }
}
