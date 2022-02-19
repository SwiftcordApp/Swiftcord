//
//  Member.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

struct Member: Codable {
    let user: User?
    let nick: String?
    let avatar: String?
    let roles: [Snowflake]
    let joined_at: ISOTimestamp
    let premium_since: ISOTimestamp? // When the user started boosting the guild
    let deaf: Bool
    let mute: Bool
    let pending: Bool?
    let permissions: String? // Total permissions of the member in the channel, including overwrites, returned when in the interaction object
    let communication_disabled_until: ISOTimestamp? // When the user's timeout will expire and the user will be able to communicate in the guild again, null or a time in the past if the user is not timed out
}
