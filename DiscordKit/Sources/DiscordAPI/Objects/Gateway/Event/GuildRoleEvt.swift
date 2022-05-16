//
//  GuildRoleEvt.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct GuildRoleEvt: Codable, GatewayData {
    public let guild_id: Snowflake
    public let role: Role
}

public struct GuildRoleDelete: Codable, GatewayData {
    public let guild_id: Snowflake
    public let role: Snowflake
}
