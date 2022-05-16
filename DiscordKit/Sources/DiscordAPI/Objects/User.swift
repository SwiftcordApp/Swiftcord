//
//  User.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public enum UserFlags: Int, CaseIterable {
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

public struct User: Codable, GatewayData {
    public let id: Snowflake
    public let username: String
    public let discriminator: String
    public let avatar: String? // User's avatar hash
    public let bot: Bool?
    public let bio: String?
    public let system: Bool?
    public let mfa_enabled: Bool? // Whether the user has two factor enabled on their account
    public let banner: String? // User's banner hash
    public let accent_color: Int?
    public let locale: Locale?
    public let verified: Bool?
    public let email: String?
    public let flags: Int?
    public let premium_type: Int?
    public let public_flags: Int?
}

// User profile endpoint is undocumented
public struct UserProfile: Codable, GatewayData {
    public let connected_accounts: [Connection]
    public let guild_member: Member?
    public let premium_guild_since: ISOTimestamp?
    public let premium_since: ISOTimestamp?
    public let mutual_guilds: [MutualGuild]?
    public let user: User // This user object contains "bio"
}

public extension User {
    var flagsArr: [UserFlags]? {
		flags?.decodeFlags(flags: UserFlags.staff)
    }
}
