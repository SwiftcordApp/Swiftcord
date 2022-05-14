//
//  Connection.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

enum ConnectionVisibility: Int, Codable {
    case none = 0 // Only visible to owner
    case everyone = 1
}

// Note: purely by observation
enum ConnectionType: String, Codable {
    case steam = "steam"
    case youtube = "youtube"
    case spotify = "spotify"
    case github = "github"
    case twitch = "twitch"
    case reddit = "reddit"
    case facebook = "facebook"
    case twitter = "twitter"
    case xbox = "xbox"
    case battleNet = "battle.net" // Guess
    // Cannot guess PlayStation Network
}

// Connections with external accounts (e.g. Reddit, YouTube, Steam etc.)
struct Connection: Codable, GatewayData {
    let id: String
    let name: String
    let type: ConnectionType
    let revoked: Bool?
    let integrations: [Integration]?
    let verified: Bool
    let friend_sync: Bool?
    let show_activity: Bool?
    let visibility: ConnectionVisibility?
}
