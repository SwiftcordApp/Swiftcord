//
//  GuildMember.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

struct GuildMemberRemove: Codable, GatewayData {
    let guild_id: Snowflake
    let user: User
}

/// Sent when a guild member is updated.
/// This will also fire when the user object of a guild member changes.
/// Very similar to Member, but with some optional value changes
struct GuildMemberUpdate: Codable, GatewayData {
    let guild_id: Snowflake
    let roles: [Snowflake] // User role IDs
    let user: User
    let nick: String?
    let avatar: String? // User's guild avatar hash
    let joined_at: ISOTimestamp?
    let premium_since: ISOTimestamp? // When user started boosting guild
    let deaf: Bool?
    let mute: Bool?
    let pending: Bool?
    let communication_disabled_until: ISOTimestamp?
}
