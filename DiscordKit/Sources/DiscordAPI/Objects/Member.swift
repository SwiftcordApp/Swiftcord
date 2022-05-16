//
//  Member.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public struct Member: Codable, GatewayData {
    public let user: User?
    public let nick: String?
    public let avatar: String?
    public let roles: [Snowflake]
    public let joined_at: ISOTimestamp
    public let premium_since: ISOTimestamp? // When the user started boosting the guild
    public let deaf: Bool
    public let mute: Bool
    public let pending: Bool?
    public let permissions: String? // Total permissions of the member in the channel, including overwrites, returned when in the interaction object
    public let communication_disabled_until: ISOTimestamp? // When the user's timeout will expire and the user will be able to communicate in the guild again, null or a time in the past if the user is not timed out
    public let guild_id: Snowflake?
}
