//
//  MessageDelete.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

struct MessageDelete: Codable, GatewayData {
    let id: Snowflake
    let channel_id: Snowflake
    let guild_id: Snowflake?
}

struct MessageDeleteBulk: Codable, GatewayData {
    let id: [Snowflake]
    let channel_id: Snowflake
    let guild_id: Snowflake?
}
