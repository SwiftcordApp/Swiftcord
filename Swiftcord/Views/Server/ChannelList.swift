//
//  ChannelList.swift
//  Swiftcord
//
//  Created by Vincent on 4/12/22.
//

import SwiftUI
import DiscordKitCommon
import DiscordKit

struct ChannelList: View {
	let channels: [Channel]
	@Binding var selCh: Channel?
	@AppStorage("nsfwShown") var nsfwShown: Bool = true
	@EnvironmentObject var serverCtx: ServerContext

	var body: some View {
		List {
			let filteredChannels = channels.filter {
				if !nsfwShown {
					return $0.parent_id == nil && $0.type != .category && ($0.nsfw == false || $0.nsfw == nil)
				}
				return $0.parent_id == nil && $0.type != .category
			}
			if !filteredChannels.isEmpty {
				Section(
					header: Text(serverCtx.guild?.isDMChannel == true
								 ? "dm"
								 : "server.channel.noCategory"
								).textCase(.uppercase)
				) {
					let channels = filteredChannels.discordSorted()
					ForEach(channels, id: \.id) { channel in
						ChannelButton(channel: channel, selectedCh: $selCh)
							.listRowInsets(.init(top: 1, leading: 0, bottom: 1, trailing: 0))
					}
				}
			}

			let categoryChannels = channels
				.filter { $0.parent_id == nil && $0.type == .category }
				.discordSorted()
			ForEach(categoryChannels, id: \.id) { channel in
				// Channels in this section
				let channels = channels.filter({
					if !nsfwShown {
						return $0.parent_id == channel.id && ($0.nsfw == false || $0.nsfw == nil)
					}
					return $0.parent_id == channel.id

				}).discordSorted()
				if !channels.isEmpty {
					Section(header: Text(channel.name ?? "").textCase(.uppercase)) {
						ForEach(channels, id: \.id) { channel in
							ChannelButton(channel: channel, selectedCh: $selCh)
								.listRowInsets(.init(top: 1, leading: 0, bottom: 1, trailing: 0))
						}
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
