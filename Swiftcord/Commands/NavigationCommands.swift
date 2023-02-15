//
//  NavigationCommands.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 26/5/22.
//

import SwiftUI
import DiscordKit
import DiscordKitCore

struct NavigationCommands: Commands {
	@ObservedObject var state: UIState
	@ObservedObject var gateway: DiscordGateway
	@State var previousServer: Snowflake?
	@AppStorage("nsfwShown") var nsfwShown: Bool = true

	var body: some Commands {
		CommandMenu("Navigation") {
			/*Button("Previous Server") {
				let guilds = (gateway.cache.guilds.values.filter({
					!(gateway.cache.userSettings?.guild_positions ?? []).contains($0.id)
				}).sorted(by: { lhs, rhs in lhs.joined_at! > rhs.joined_at! }))
				+ (gateway.cache.userSettings?.guild_positions ?? [])
					.compactMap({ gateway.cache.guilds[$0] })

				guard let previousGuild = guilds.before(state.serverCtx.guild!, loop: true) else { return }

				state.selectedGuildID = previousGuild.id
			}.keyboardShortcut(.upArrow, modifiers: [.command, .option])

			Button("Next Server") {
				let guilds = (gateway.cache.guilds.values.filter({
					!(gateway.cache.userSettings?.guild_positions ?? []).contains($0.id)
				}).sorted(by: { lhs, rhs in lhs.joined_at! > rhs.joined_at! }))
				+ (gateway.cache.userSettings?.guild_positions ?? [])
					.compactMap({ gateway.cache.guilds[$0] })

				guard let nextGuild = guilds.after(state.serverCtx.guild!, loop: true) else { return }

				state.selectedGuildID = nextGuild.id
			}.keyboardShortcut(.downArrow, modifiers: [.command, .option])*/

			Divider()

			Button("Previous Channel") {
				if let channels = state.serverCtx.guild?.channels {
					let sortedChannels = sortChannels(channels)

					guard let previousChannel = sortedChannels.before(state.serverCtx.channel!, loop: true) else { return }

					state.serverCtx.channel = previousChannel
				}
			}.keyboardShortcut(.upArrow, modifiers: [.option])

			Button("Next Channel") {
				if let channels = state.serverCtx.guild?.channels {
					let sortedChannels = sortChannels(channels)

					guard let nextChannel = sortedChannels.after(state.serverCtx.channel!, loop: true) else { return }

					state.serverCtx.channel = nextChannel
				}
			}.keyboardShortcut(.downArrow, modifiers: [.option])

			Divider()

			Button("DMs") {
				if state.selectedGuildID != "@me" {
					previousServer = state.selectedGuildID
					state.selectedGuildID = "@me"
				} else {
					if previousServer != nil {
						state.selectedGuildID = previousServer
					}
				}
			}.keyboardShortcut(.rightArrow, modifiers: [.command, .option])

//			Button("Create/Join Server") {}
//				.keyboardShortcut("N", modifiers: [.command, .shift])
		}
	}

	func sortChannels(_ channels: [Channel]) -> [Channel] {
		var filteredChannels = channels.filter {
			if !nsfwShown {
				return $0.parent_id == nil && $0.type != .category && $0.type != .voice && ($0.nsfw == false || $0.nsfw == nil)
			}
			return $0.parent_id == nil && $0.type != .category && $0.type != .voice

		}.discordSorted()
		if !nsfwShown {
			filteredChannels = filteredChannels.filter({ $0.nsfw == false })
		}
		var sortedChannels = filteredChannels

		let categories = channels
				.filter { $0.parent_id == nil && $0.type == .category }
				.discordSorted()
		for category in categories {
			let categoryChannels = channels.filter({
				if !nsfwShown {
					return $0.parent_id == category.id && $0.type != .category && $0.type != .voice && ($0.nsfw == false || $0.nsfw == nil)
				}
				return $0.parent_id == category.id && $0.type != .category && $0.type != .voice
			}).discordSorted()
			sortedChannels.append(contentsOf: categoryChannels)
		}

		return sortedChannels
	}
}
