//
//  Permission.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

public enum PermOverwriteType: Int, Codable {
    case role = 0
    case member = 1
}

public struct PermOverwrite: Codable {
    public let id: Snowflake
    public let type: PermOverwriteType
    public let allow: String
    public let deny: String
}

/*
 From discord docs:
 Roles represent a set of permissions attached to a group of users.
 Roles have names, colors, and can be "pinned" to the side bar,
 causing their members to be listed separately. Roles can have
 separate permission profiles for the global context (guild) and
 channel context. The @everyone role has the same ID as the guild it belongs to.
 */

public struct Role: Codable {
    public let id: Snowflake
    public let name: String
    public let color: Int
    public let hoist: Bool // If this role is pinned in the user listing
    public let icon: String? // Role icon hash
    public let unicode_emoji: String?
    public let position: Int
    public let permissions: String // Permission bit set
    public let managed: Bool // Whether this role is managed by an integration
    public let mentionable: Bool
    public let tags: RoleTags?
}

public struct RoleTags: Codable {
    public let bot_id: Snowflake?
    public let integration_id: Snowflake?
    public let premium_subscriber: Bool?
}
