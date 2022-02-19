//
//  Mention.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

enum AllowedMentionTypes: String, Codable {
    case role = "roles" // Controls role mentions
    case user = "users" // Controls user mentions
    case everyone = "everyone" // Controls @everyone and @here mentions
}

struct AllowedMentions: Codable {
    let parse: [AllowedMentionTypes]? // An array of allowed mention types to parse from the content.
    let roles: [Snowflake]? // Array of role_ids to mention (Max size of 100)
    let users: [Snowflake]? // Array of user_ids to mention (Max size of 100)
    let replied_user: Bool? // For replies, whether to mention the author of the message being replied to (default false)
}

struct ChannelMention: Codable {
    let id: Snowflake
    let guild_id: Snowflake
    let type: ChannelType
    let name: String
}
