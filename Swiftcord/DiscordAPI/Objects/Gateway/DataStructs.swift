//
//  DataStructs.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

protocol GatewayData: Decodable {}
protocol OutgoingGatewayData: Encodable {}

struct GatewayConnProperties: OutgoingGatewayData {
    let os: String
    let browser: String
    let release_channel: String?
    let client_version: String?
    let os_version: String?
    let os_arch: String?
    let system_locale: String?
    let client_build_number: Int?
}

// MARK: Opcode 1 (Heartbeat)
struct GatewayHeartbeat: OutgoingGatewayData {}

// MARK: Opcode 2 (Identify)
struct GatewayIdentify: OutgoingGatewayData {
    let token: String
    let properties: GatewayConnProperties
    let compress: Bool?
    let large_threshold: Int? // Value between 50 and 250, total number of members where the gateway will stop sending offline members in the guild member list
    let shard: [Int]? // Array of two integers (shard_id, num_shards)
    let presence: GatewayPresenceUpdate?
    let capabilities: Int // Hardcode this to 253
}

// MARK: Opcode 3 (Presence Update)
struct GatewayPresenceUpdate: OutgoingGatewayData {
    let since: Int // Unix time (in milliseconds) of when the client went idle, or null if the client is not idle
    let activities: [ActivityOutgoing]
    let status: String
    let afk: Bool
}

// MARK: Opcode 4 (Voice State Update)
struct GatewayVoiceStateUpdate: OutgoingGatewayData, GatewayData {
    let guild_id: Snowflake?
    let channel_id: Snowflake? // ID of the voice channel client wants to join (null if disconnecting)
    let self_mute: Bool
    let self_deaf: Bool
    let self_video: Bool?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Encoding containers directly so nil optionals get encoded as "null" and not just removed
        try container.encode(self_mute, forKey: .self_mute)
        try container.encode(self_deaf, forKey: .self_deaf)
        try container.encode(self_video, forKey: .self_video)
        try container.encode(channel_id, forKey: .channel_id)
        try container.encode(guild_id, forKey: .guild_id)
    }
}

// MARK: Opcode 6 (Resume)
struct GatewayResume: OutgoingGatewayData {
    let token: String
    let session_id: String
    let seq: Int // Last sequence number received
}

// MARK: Opcode 8 (Guild Request Members)
struct GatewayGuildRequestMembers: GatewayData {
    let guild_id: Snowflake
    let query: String?
    let limit: Int
    let presences: Bool? // Used to specify if we want the presences of the matched members
    let user_ids: [Snowflake]? // Used to specify which users you wish to fetch
    let nonce: String? // Nonce to identify the Guild Members Chunk response
}

// MARK: Opcode 10 (Hello)
struct GatewayHello: GatewayData {
    let heartbeat_interval: Int
}

// MARK: Opcode 14 (Subscribe Guild Events)
struct SubscribeGuildEvts: OutgoingGatewayData {
    let guild_id: Snowflake
    var typing: Bool = false
    var activities: Bool = false
    var threads: Bool = false
}
