//
//  Stage.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public enum StageDiscovery: Int, Codable {
    case `public` = 1 // Depreciated
    case guildOnly = 2
}

public struct StageInstance: Codable, GatewayData {
    public let id: Snowflake
    public let guild_id: Snowflake
    public let channel_id: Snowflake
    public let topic: String
    public let privacy_level: StageDiscovery
    public let discoverable_disabled: Bool // Depreciated
}
