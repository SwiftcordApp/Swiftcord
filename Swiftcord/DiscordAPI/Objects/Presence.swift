//
//  Presence.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

// TODO: Fill this in
struct Presence: Codable {
    
}

enum PresenceStatus: String, Codable {
    case idle = "idle"
    case dnd = "dnd"
    case online = "online"
    case offline = "offline"
}

struct PresenceUpdate: Codable, GatewayData {
    let user: User
    let guild_id: Snowflake
    let status: PresenceStatus
    let activities: Activity
    let client_status: PresenceClientStatus
}

struct PresenceClientStatus: Codable, GatewayData {
    let desktop: String?
    let mobile: String?
    let web: String?
}
