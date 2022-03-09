//
//  User.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

enum UserFlags: Int, CaseIterable {
    case staff = 0
    case partner = 1
    case hypesquadEvents = 2
    case bugHunterLv1 = 3
    case hypesquadBravery = 6
    case hypesquadBrilliance = 7
    case hypesquadBalance = 8
    case earlySupporter = 9
    case teamPseudoUser = 10
    case bugHunterLv2 = 14
    case verifiedBot = 16
    case verifiedDev = 17
    case certifiedMod = 18
    case botHTTPInteractions = 19
}

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

extension User {
    var flagsArr: [UserFlags]? {
        set {}
        get { return flags?.decodeFlags(flags: UserFlags.staff) }
    }
}
