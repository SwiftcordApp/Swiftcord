//
//  ThreadListSync.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

struct ThreadListSync: Codable, GatewayData {
    let guild_id: Snowflake
    let channel_ids: [Snowflake]?
    let threads: [Channel]
    let members: [ThreadMember]
}
