//
//  TypingStart.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 12/5/22.
//

import Foundation

struct TypingStart: Codable, GatewayData {
    let user_id: Snowflake
    let channel_id: Snowflake
    let guild_id: Snowflake
    let timestamp: Int
    let member: Member
}
