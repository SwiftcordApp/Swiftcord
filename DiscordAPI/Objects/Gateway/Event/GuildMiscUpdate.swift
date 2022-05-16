//
//  GuildMiscUpdate.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

struct GuildEmojisUpdate: Codable, GatewayData {
    let guild_id: Snowflake
    let emojis: [Emoji]
}

struct GuildStickersUpdate: Codable, GatewayData {
    let guild_id: Snowflake
    let stickers: [Sticker]
}

struct GuildIntegrationsUpdate: Codable, GatewayData {
    let guild_id: Snowflake
}
