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
			.contextMenu {
				let isRead = gateway.readState[channel.id]?.id == channel.last_message_id
				Button(action: { readChannel(channel) }) {
					Image(systemName: isRead ? "message" : "message.badge")
					Text("Mark as read")
				}.disabled(isRead)
				
				Divider()
				
				Group {
					Button(action: { copyLink(channel) }) {
						Image(systemName: "link")
						Text("Copy Link")
					}
					Button(action: { copyId(channel) }) {
						Image(systemName: "number.circle.fill")
						Text("Copy ID")
					}
				}
			}
	}

	var body: some View {
		List {
			Spacer(minLength: 52 - 16 + 4) // 52 (header) - 16 (unremovable section top padding) + 4 (spacing)

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
					ForEach(channels, id: \.id) { channel in item(for: channel) }
				}
			}

			let categoryChannels = channels
				.filter { $0.parent_id == nil && $0.type == .category }
				.discordSorted()
			ForEach(categoryChannels, id: \.id) { channel in
				// Channels in this section
				let channels = channels.filter {
					if !nsfwShown {
						return $0.parent_id == channel.id && ($0.nsfw == false || $0.nsfw == nil)
					}
					return $0.parent_id == channel.id
				}.discordSorted()
				if !channels.isEmpty {
					Section(header: Text(channel.name ?? "").textCase(.uppercase).padding(.leading, 8)) {
						ForEach(channels, id: \.id) { channel in item(for: channel) }
					}
					.contextMenu {
						Button(action: { readChannels(channels) }) {
							Image(systemName: "message.badge")
							Text("Mark as read")
						}
						
						Divider()
						
						Button(action: { copyId(channel) }) {
							Image(systemName: "number.circle.fill")
							Text("Copy ID")
						}
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
}

private extension ChannelList {
	func readChannels(_ channels: [Channel]) {
		for channel in channels {
			readChannel(channel)
		}
	}
	
	func readChannel(_ channel: Channel) {
		gateway.readState[channel.id] = gateway.readState[channel.id]?.updatingLastMessage(id: channel.last_message_id ?? "")
	}
	
	func copyLink(_ channel: Channel) {
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		pasteboard.setString(
			"https://canary.discord.com/channels/\(channel.guild_id ?? "@me")/\(channel.id)",
			forType: .string
		)
	}
	
	func copyId(_ channel: Channel) {
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		pasteboard.setString(
			channel.id,
			forType: .string
		)
	}
}
