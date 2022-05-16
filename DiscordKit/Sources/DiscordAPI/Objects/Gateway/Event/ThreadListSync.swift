//
//  ThreadListSync.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct ThreadListSync: Codable, GatewayData {
    public let guild_id: Snowflake
    public let channel_ids: [Snowflake]?
    public let threads: [Channel]
    public let members: [ThreadMember]
}
