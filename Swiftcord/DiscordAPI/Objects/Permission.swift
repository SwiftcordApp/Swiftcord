//
//  Permission.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

enum PermOverwriteType: Int, Codable {
    case role = 0
    case member = 1
}

struct PermOverwrite: Codable {
    let id: Snowflake
    let type: PermOverwriteType
    let allow: String
    let deny: String
}

/*
 From discord docs:
 Roles represent a set of permissions attached to a group of users.
 Roles have names, colors, and can be "pinned" to the side bar,
 causing their members to be listed separately. Roles can have
 separate permission profiles for the global context (guild) and
 channel context. The @everyone role has the same ID as the guild it belongs to.
 */

struct Role: Codable {
    let id: Snowflake
    let name: String
    let color: Int
    let hoist: Bool // If this role is pinned in the user listing
    let icon: String? // Role icon hash
    let unicode_emoji: String?
    let position: Int
    let permissions: String // Permission bit set
    let managed: Bool // Whether this role is managed by an integration
    let mentionable: Bool
    let tags: RoleTags?
}

struct RoleTags: Codable {
    let bot_id: Snowflake?
    let integration_id: Snowflake?
    let premium_subscriber: Bool?
}
