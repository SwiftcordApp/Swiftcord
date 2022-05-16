//
//  Emoji.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public struct Emoji: Codable {
    public let id: Snowflake?
    public let name: String? // Can be null only in reaction emoji objects
    public let roles: [Role]?
    public let user: User? // User that created this emoji
    public let require_colons: Bool? // Whether this emoji must be wrapped in colons
    public let managed: Bool?
    public let animated: Bool?
    public let available: Bool? // Whether this emoji can be used, may be false due to loss of Server Boosts
}
