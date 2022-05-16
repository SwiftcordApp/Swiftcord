//
//  GuildMiscUpdateEvents.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct GuildEmojisUpdateEventData: Codable, GatewayData {
	public let guild_id: Snowflake
	public let emojis: [Emoji]
}

public struct GuildStickersUpdateEventData: Codable, GatewayData {
	public let guild_id: Snowflake
	public let stickers: [Sticker]
}

public struct GuildIntegrationsUpdateEventData: Codable, GatewayData {
	public let guild_id: Snowflake
}
