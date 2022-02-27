//
//  User.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

struct User: Codable {
    let id: Snowflake
    let username: String
    let discriminator: String
    let avatar: String? // User's avatar hash
    let bot: Bool?
    let bio: String?
    let system: Bool?
    let mfa_enabled: Bool? // Whether the user has two factor enabled on their account
    let banner: String? // User's banner hash
    let accent_color: Int?
    let locale: Locale?
    let verified: Bool?
    let email: String?
    let flags: Int?
    let premium_type: Int?
    let public_flags: Int?
}

// User profile endpoint is undocumented
struct UserProfile: Codable, GatewayData {
    let connected_accounts: [Connection]
    let guild_member: Member?
    let premium_guild_since: ISOTimestamp?
    let premium_since: ISOTimestamp?
    let mutual_guilds: [MutualGuild]?
    let user: User // This user object contains "bio"
}
