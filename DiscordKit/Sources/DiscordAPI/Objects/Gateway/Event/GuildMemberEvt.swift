//
//  GuildMember.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct GuildMemberRemove: Codable, GatewayData {
    public let guild_id: Snowflake
    public let user: User
}

/// Sent when a guild member is updated.
/// This will also fire when the user object of a guild member changes.
/// Very similar to Member, but with some optional value changes
public struct GuildMemberUpdate: Codable, GatewayData {
    public let guild_id: Snowflake
    public let roles: [Snowflake] // User role IDs
    public let user: User
    public let nick: String?
    public let avatar: String? // User's guild avatar hash
    public let joined_at: ISOTimestamp?
    public let premium_since: ISOTimestamp? // When user started boosting guild
    public let deaf: Bool?
    public let mute: Bool?
    public let pending: Bool?
    public let communication_disabled_until: ISOTimestamp?
}
