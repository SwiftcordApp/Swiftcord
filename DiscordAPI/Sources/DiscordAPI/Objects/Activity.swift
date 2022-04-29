//
//  Activity.swift
//  Native Discord
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

enum ActivityType: Int, Codable {
    case game = 0      // Playing {name}
    case streaming = 1 // Streaming {details}
    case listening = 2 // Listening to {name}
    case watching = 3  // Watching {name}
    case custom = 4    // {emoji} {name}
    case competing = 5 // Competing in {name}
}

struct Activity: Codable {
    let name: String
    let type: ActivityType
    let url: String?
    let created_at: Int // Unix timestamp (in milliseconds) of when the activity was added to the user's session
    let timestamps: [ActivityTimestamp]?
    let application_id: Snowflake?
    let details: String?
    let state: String?
    let emoji: ActivityEmoji?
    let party: ActivityParty?
    let assets: ActivityAssets?
    let secrets: ActivitySecrets?
    let instance: Bool?
    let flags: Int?
    let buttons: [ActivityButton]?
}

struct ActivityTimestamp: Codable {
    let start: Int? // Unix time (in milliseconds) of when the activity started
    let end: Int? // Unix time (in milliseconds) of when the activity ended
}

struct ActivityEmoji: Codable {
    let name: String
    let id: Snowflake?
    let animated: Bool?
}

struct ActivityParty: Codable {
    let id: String? // The ID of the party (for some reason it's not a Snowflake)
    let size: [Int]? // Array of two integers (current_size, max_size)
}

struct ActivityAssets: Codable {
    let large_image: String?
    let large_text: String? // Text displayed when hovering over the large image of the activity
    let small_image: String?
    let small_text: String?
}

struct ActivitySecrets: Codable {
    let join: String?
    let spectate: String?
    let match: String? // The secret for a specific instanced match
}

struct ActivityButton: Codable {
    let label: String
    let url: String
}
