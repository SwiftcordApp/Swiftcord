//
//  NavigationCommands.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 26/5/22.
//

import SwiftUI
import DiscordKit

struct NavigationCommands: Commands {
	@ObservedObject var state: UIState
	@ObservedObject var gateway: DiscordGateway

    var body: some Commands {
		CommandMenu("Navigation") {
			Button("Previous Server") {
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
			}.keyboardShortcut(.downArrow, modifiers: [.command, .option])

			Divider()

			Button("Previous Channel") {
				if let channels = state.serverCtx.guild?.channels {
					let filteredChannels = channels.filter { $0.type != .category && $0.type != .voice }
					let sortedChannels = filteredChannels.discordSorted()

					guard let previousChannel = sortedChannels.before(state.serverCtx.channel!, loop: true) else { return }

					state.serverCtx.channel = previousChannel
				}
			}.keyboardShortcut(.upArrow, modifiers: [.option])

			Button("Next Channel") {
				if let channels = state.serverCtx.guild?.channels {
					let filteredChannels = channels.filter { $0.type != .category && $0.type != .voice }
					let sortedChannels = filteredChannels.discordSorted()

					guard let nextChannel = sortedChannels.after(state.serverCtx.channel!, loop: true) else { return }

					state.serverCtx.channel = nextChannel
				}
			}.keyboardShortcut(.downArrow, modifiers: [.option])

			Divider()

			Button("DMs") {
				state.selectedGuildID = "@me"
			}.keyboardShortcut(.rightArrow, modifiers: [.command, .option])

//			Button("Create/Join Server") {}
//				.keyboardShortcut("N", modifiers: [.command, .shift])
		}
    }
}
