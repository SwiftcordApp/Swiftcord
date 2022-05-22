//
//  ChannelList.swift
//  Swiftcord
//
//  Created by Vincent on 4/12/22.
//

import SwiftUI
import DiscordKit

struct ChannelList: View {
	let channels: [Channel]
	@Binding var selCh: Channel?
	let guild: Guild

	var body: some View {
		List {
			let filteredChannels = channels.filter { $0.parent_id == nil && $0.type != .category }
			if !filteredChannels.isEmpty {
				let sectionHeadline = guild.isDMChannel ? "DMs" : "No category"
				Section(header: Text(sectionHeadline)) {
					let channels = filteredChannels.discordSorted()
					ForEach(channels) { channel in
						ChannelButton(channel: channel, guild: guild, selectedCh: $selCh)
							.listRowInsets(.init(top: 1, leading: 8, bottom: 1, trailing: 8))
					}
				}
			}

			let categoryChannels = channels.filter({ c in c.parent_id == nil && c.type == .category }).discordSorted()
			ForEach(categoryChannels) { ch in
				Section(header: Text(ch.name?.uppercased() ?? "")) {
					// Channels in this section
					let channels = channels.filter({ $0.parent_id == ch.id }).discordSorted()
					ForEach(channels) { channel in
						ChannelButton(channel: channel, guild: guild, selectedCh: $selCh)
							.listRowInsets(.init(top: 1, leading: 8, bottom: 1, trailing: 8))
					}
				}

			}
		}
		.padding(.top, 10)
		.listStyle(.sidebar)
		.frame(minWidth: 240, maxHeight: .infinity)
		// this overlay applies a border on the bottom edge of the view
		.overlay(Rectangle().fill(Color(nsColor: .separatorColor)).frame(width: nil, height: 1, alignment: .bottom), alignment: .top)
	}
}
