//
//  Stage.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

enum StageDiscovery: Int, Codable {
    case `public` = 1 // Depreciated
    case guildOnly = 2
}

struct StageInstance: Codable, GatewayData {
    let id: Snowflake
    let guild_id: Snowflake
    let channel_id: Snowflake
    let topic: String
    let privacy_level: StageDiscovery
    let discoverable_disabled: Bool // Depreciated
}
