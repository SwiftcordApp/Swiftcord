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

struct PresenceUser: Codable, GatewayData {
    let id: Snowflake
    let username: String?
    let discriminator: String?
    let avatar: String?
}

struct PresenceUpdate: GatewayData {
    let user: PresenceUser
    let guild_id: Snowflake?
    let status: PresenceStatus
    let activities: [Activity]
    let client_status: PresenceClientStatus
}

struct PartialPresenceUpdate: GatewayData {
    let user: PresenceUser
    let guild_id: Snowflake?
    let status: PresenceStatus?
    let activities: [Activity]?
    let client_status: PresenceClientStatus?
}

struct PresenceClientStatus: Codable, GatewayData {
    let desktop: String?
    let mobile: String?
    let web: String?
}
