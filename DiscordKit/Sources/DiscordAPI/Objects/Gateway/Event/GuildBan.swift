//
//  GuildBan.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct GuildBan: Codable, GatewayData {
    public let guild_id: Snowflake
    public let user: User
}
