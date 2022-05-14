//
//  GuildRoleEvt.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

struct GuildRoleEvt: Codable, GatewayData {
    let guild_id: Snowflake
    let role: Role
}

struct GuildRoleDelete: Codable, GatewayData {
    let guild_id: Snowflake
    let role: Snowflake
}
