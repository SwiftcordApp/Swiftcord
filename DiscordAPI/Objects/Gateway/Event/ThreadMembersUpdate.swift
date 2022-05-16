//
//  ThreadMembersUpdate.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

struct ThreadMembersUpdate: Codable, GatewayData {
    let id: Snowflake
    let guild_id: Snowflake
    let member_count: Int // The approximate number of members in the thread, capped at 50
    let added_members: [ThreadMember]?
    let removed_member_ids: [Snowflake]?
}
