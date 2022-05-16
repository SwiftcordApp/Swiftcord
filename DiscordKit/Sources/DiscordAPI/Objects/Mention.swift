//
//  Mention.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public enum AllowedMentionTypes: String, Codable {
    case role = "roles" // Controls role mentions
    case user = "users" // Controls user mentions
    case everyone = "everyone" // Controls @everyone and @here mentions
}

public struct AllowedMentions: Codable {
    public let parse: [AllowedMentionTypes]? // An array of allowed mention types to parse from the content.
    public let roles: [Snowflake]? // Array of role_ids to mention (Max size of 100)
    public let users: [Snowflake]? // Array of user_ids to mention (Max size of 100)
    public let replied_user: Bool? // For replies, whether to mention the author of the message being replied to (default false)
}

public struct ChannelMention: Codable {
    public let id: Snowflake
    public let guild_id: Snowflake
    public let type: ChannelType
    public let name: String
}
