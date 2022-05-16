//
//  GuildBan.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

struct GuildBan: Codable, GatewayData {
    let guild_id: Snowflake
    let user: User
}
