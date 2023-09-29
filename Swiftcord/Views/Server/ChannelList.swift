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
struct ChannelList: View, Equatable {
	let channels: [Channel]
	@Binding var selCh: Channel?
	@AppStorage("nsfwShown") var nsfwShown: Bool = true
	@EnvironmentObject var serverCtx: ServerContext
	@EnvironmentObject var gateway: DiscordGateway

	@_transparent @_optimize(speed) @ViewBuilder
	private func item(for channel: Channel) -> some View {
		ChannelButton(channel: channel, selectedCh: $selCh)
			.equatable()
			.listRowInsets(.init(top: 1, leading: 0, bottom: 1, trailing: 0))
			.listRowBackground(Spacer().overlay(alignment: .leading) {
				// Check if we should show unread indicator
				if let lastID = gateway.readState[channel.id]?.last_message_id, let _chLastID = channel.last_message_id, let chLastID = Int(_chLastID), lastID.intValue < chLastID {
					Circle().fill(.primary).frame(width: 8, height: 8).offset(x: 2)
				}
			})
	}

	var body: some View {
		let availableChs = channels.filter { channel in
			guard let guildID = serverCtx.guild?.id, let member = serverCtx.member else {
				// print("no guild or member!")
				return true
			}
			guard channel.type != .category else {
				return true
			}
			return channel.computedPermissions(
				guildID: guildID,
				member: member,
				basePerms: serverCtx.basePermissions
			)
			.contains(.viewChannel)
		}
		List {
			// Spacer(minLength: 4).listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0)) // 38 (header) - 16 (unremovable section top padding) + 4 (spacing)

			let filteredChannels = availableChs.filter {
				$0.parent_id == nil && $0.type != .category && (nsfwShown || ($0.nsfw == false || $0.nsfw == nil))
			}
			if !filteredChannels.isEmpty {
				Section(
					header: Text(serverCtx.guild?.properties.isDMChannel == true
						? "dm"
						: "server.channel.noCategory"
					).textCase(.uppercase).padding(.leading, 8)
				) {
					let channels = filteredChannels.discordSorted()
					ForEach(channels, id: \.id) { channel in item(for: channel) }
				}
			}

			let categoryChannels = availableChs
				.filter { $0.parent_id == nil && $0.type == .category }
				.discordSorted()
			ForEach(categoryChannels, id: \.id) { channel in
				// Channels in this section
				let channels = availableChs.filter {
					$0.parent_id == channel.id && (nsfwShown || ($0.nsfw == false || $0.nsfw == nil))
				}.discordSorted()
				if !channels.isEmpty {
					Section(header: Text(channel.name ?? "").textCase(.uppercase).padding(.leading, 8)) {
						ForEach(channels, id: \.id) { channel in item(for: channel) }
					}
				}
			}
		}
		.environment(\.defaultMinListRowHeight, 1)
		.padding(.horizontal, -6)
		.listStyle(.sidebar)
		.frame(minWidth: 240, maxHeight: .infinity)
		.introspectTableView { tableView in
			tableView.enclosingScrollView!.scrollerInsets = .init(top: 0, left: 0, bottom: 0, right: 6)
			tableView.enclosingScrollView!.automaticallyAdjustsContentInsets = false
			tableView.enclosingScrollView!.contentInsets = .init()
		}
		.environment(\.defaultMinListRowHeight, 1)
	}

	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.channels == rhs.channels && lhs.selCh == rhs.selCh
	}
}
