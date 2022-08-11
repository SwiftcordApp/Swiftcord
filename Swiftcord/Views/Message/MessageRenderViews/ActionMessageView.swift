//
//  ActionMessageView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 11/8/22.
//

import SwiftUI
import DiscordKitCommon

/// Action messages: e.g. member leave, join etc.
struct ActionMessageView: View {
	let message: Message

	private struct ActionMessageData {
		let message: LocalizedStringKey
		let icon: String
		let color: Color
	}

	// Trust, this might seem messy but it's more scalable than putting the
	// views themselves in a huge if tree
	private var data: ActionMessageData {
		switch message.type {
		case .guildMemberJoin:
			return ActionMessageData(
				message: "**\(message.author.username)** joined this server.",
				icon: "arrow.right",
				color: .green
			)
		case .recipientAdd:
			return ActionMessageData(
				message: "**\(message.author.username)** added **\(message.mentions[0].username)** to the group.",
				icon: "arrow.right",
				color: .green
			)
		case .recipientRemove:
			return ActionMessageData(
				message: "**\(message.author.username)** left the group.",
				icon: "arrow.left",
				color: .red
			)
		case .userPremiumGuildSub:
			return ActionMessageData(
				message: "**\(message.author.username)** just boosted the server!",
				icon: "rhombus.fill",
				color: .purple
			)
		case .userPremiumGuildSubTier1:
			return ActionMessageData(
				message: "**\(message.author.username)** just boosted the server! This server has achieved **Level 1!**",
				icon: "rhombus.fill",
				color: .purple
			)
		case .userPremiumGuildSubTier2:
			return ActionMessageData(
				message: "**\(message.author.username)** just boosted the server! This server has achieved **Level 2!**",
				icon: "rhombus.fill",
				color: .purple
			)
		case .userPremiumGuildSubTier3:
			return ActionMessageData(
				message: "**\(message.author.username)** just boosted the server! This server has achieved **Level 3!**",
				icon: "rhombus.fill",
				color: .purple
			)
		default:
			return ActionMessageData(
				message: "Oops, rendering `\(String(describing: message.type))` messages aren't supported yet :(",
				icon: "questionmark",
				color: .gray
			)
		}
	}

	var body: some View {
		Image(systemName: data.icon)
			.foregroundColor(data.color)
			.font(.system(size: 16))
			.padding([.leading, .trailing], 12)
		Group {
			Text(data.message).font(.system(size: 14))
			+ Text(" ").font(.system(size: 14))
			+ Text(DateFormatter.messageDateFormatter.string(from: message.timestamp))
				.font(.system(size: 12))
		}.opacity(0.75)
	}
}
