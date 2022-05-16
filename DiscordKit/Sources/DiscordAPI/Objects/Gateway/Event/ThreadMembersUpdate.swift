//
//  ThreadMembersUpdate.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct ThreadMembersUpdate: Codable, GatewayData {
    public let id: Snowflake
    public let guild_id: Snowflake
    public let member_count: Int // The approximate number of members in the thread, capped at 50
    public let added_members: [ThreadMember]?
    public let removed_member_ids: [Snowflake]?
}
