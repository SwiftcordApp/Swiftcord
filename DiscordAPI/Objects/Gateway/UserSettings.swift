//
//  UserSettings.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 10/5/22.
//

import Foundation

struct UserSettings: Decodable, GatewayData {
    let guild_positions: [Snowflake]
    let guild_folders: [GuildFolder]
}
