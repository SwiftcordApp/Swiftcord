//
//  Emoji.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

struct Emoji: Codable {
    let id: Snowflake?
    let name: String? // Can be null only in reaction emoji objects
    let roles: [Role]?
    let user: User? // User that created this emoji
    let require_colons: Bool? // Whether this emoji must be wrapped in colons
    let managed: Bool?
    let animated: Bool?
    let available: Bool? // Whether this emoji can be used, may be false due to loss of Server Boosts
}
