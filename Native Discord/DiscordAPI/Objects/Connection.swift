//
//  Connection.swift
//  Native Discord
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

enum ConnectionVisibility: Int, Codable {
    case none = 0 // Only visible to owner
    case everyone = 1
}

// Connections with external accounts (e.g. Reddit, YouTube, Steam etc.)
struct Connection: Codable, GatewayData {
    let id: String
    let name: String
    let type: String
    let revoked: Bool?
    let integrations: [Integration]?
    let verified: Bool
    let friend_sync: Bool
    let show_activity: Bool
    let visibility: ConnectionVisibility
}
