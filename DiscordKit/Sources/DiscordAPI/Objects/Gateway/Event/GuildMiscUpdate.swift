//
//  GuildMiscUpdate.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct GuildEmojisUpdate: Codable, GatewayData {
    public let guild_id: Snowflake
    public let emojis: [Emoji]
}

public struct GuildStickersUpdate: Codable, GatewayData {
    public let guild_id: Snowflake
    public let stickers: [Sticker]
}

public struct GuildIntegrationsUpdate: Codable, GatewayData {
    public let guild_id: Snowflake
}
