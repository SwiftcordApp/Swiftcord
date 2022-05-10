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
            if !channels.filter { ch in ch.parent_id == nil && ch.type != .category }.isEmpty {
                Section(header: Text("NO CATEGORY")) {
                    ForEach(
                        filterAndSortChannels(channels) { c in
                            c.parent_id == nil && c.type != .category
                        },
                        id: \.id
                    ) { channel in
                        ChannelButton(channel: channel, guild: guild, selectedCh: $selCh)
                            .listRowInsets(.init(top: 1, leading: 0, bottom: 1, trailing: 0))
                    }
                }.padding(.horizontal, 16)
            }
            
            ForEach(
                filterAndSortChannels(channels) { ch in ch.parent_id == nil && ch.type == .category },
                id: \.id
            ) { ch in
                Section(header: Text(ch.name?.uppercased() ?? "")) {
                    ForEach(
                        filterAndSortChannels(channels) { c in c.parent_id == ch.id },
                        id: \.id
                    ) { channel in
                        ChannelButton(channel: channel, guild: guild, selectedCh: $selCh)
                            .listRowInsets(.init(top: 1, leading: 0, bottom: 1, trailing: 0))
                    }
                }.padding(.horizontal, 16)
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, -14) // Horrible hack to work around List's clipping to bounds
        .listStyle(.sidebar)
        .frame(minWidth: 240, maxHeight: .infinity)
        // this overlay applies a border on the bottom edge of the view
        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color(nsColor: .separatorColor)), alignment: .top)
    }
}
