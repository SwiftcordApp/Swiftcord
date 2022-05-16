//
//  TypingStart.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 12/5/22.
//

import Foundation

public struct TypingStart: Codable, GatewayData {
    public let user_id: Snowflake
    public let channel_id: Snowflake
    public let guild_id: Snowflake?
    public let timestamp: Int
    public let member: Member?
}
