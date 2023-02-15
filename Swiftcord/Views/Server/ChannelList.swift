//
//  ChannelList.swift
//  Swiftcord
//
//  Created by Vincent on 4/12/22.
//

import SwiftUI
import Introspect
import DiscordKitCore
import DiscordKit

/// Renders the channel list on the sidebar
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
					).textCase(.uppercase).padding(.leading, 8)
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
					Section(header: Text(channel.name ?? "").textCase(.uppercase).padding(.leading, 8)) {
						ForEach(channels, id: \.id) { channel in
							ChannelButton(channel: channel, selectedCh: $selCh)
								.listRowInsets(.init(top: 1, leading: 0, bottom: 1, trailing: 0))
						}
					}
				}
			}
		}
		.padding(.horizontal, -6)
		.listStyle(.sidebar)
		.frame(minWidth: 240, maxHeight: .infinity)
		.introspectTableView { tableView in
			tableView.enclosingScrollView?.scrollerInsets = .init(top: 0, left: 0, bottom: 0, right: 6)
		}
		.environment(\.defaultMinListRowHeight, 1)
	}
}
