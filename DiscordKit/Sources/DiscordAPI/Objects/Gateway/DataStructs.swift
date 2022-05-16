//
//  DataStructs.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

public protocol GatewayData: Decodable {}
public protocol OutgoingGatewayData: Encodable {}

public struct GatewayConnProperties: OutgoingGatewayData {
    public let os: String
    public let browser: String
    public let release_channel: String?
    public let client_version: String?
    public let os_version: String?
    public let os_arch: String?
    public let system_locale: String?
    public let client_build_number: Int?
}

// MARK: Opcode 1 (Heartbeat)
public struct GatewayHeartbeat: OutgoingGatewayData {}

// MARK: Opcode 2 (Identify)
public struct GatewayIdentify: OutgoingGatewayData {
    public let token: String
    public let properties: GatewayConnProperties
    public let compress: Bool?
    public let large_threshold: Int? // Value between 50 and 250, total number of members where the gateway will stop sending offline members in the guild member list
    public let shard: [Int]? // Array of two integers (shard_id, num_shards)
    public let presence: GatewayPresenceUpdate?
    public let capabilities: Int // Hardcode this to 253
}

// MARK: Opcode 3 (Presence Update)
public struct GatewayPresenceUpdate: OutgoingGatewayData {
    public let since: Int // Unix time (in milliseconds) of when the client went idle, or null if the client is not idle
    public let activities: [ActivityOutgoing]
    public let status: String
    public let afk: Bool
}

// MARK: Opcode 4 (Voice State Update)
public struct GatewayVoiceStateUpdate: OutgoingGatewayData, GatewayData {
    public let guild_id: Snowflake?
    public let channel_id: Snowflake? // ID of the voice channel client wants to join (null if disconnecting)
    public let self_mute: Bool
    public let self_deaf: Bool
    public let self_video: Bool?

	public init(guild_id: Snowflake?, channel_id: Snowflake?, self_mute: Bool, self_deaf: Bool, self_video: Bool?) {
		self.guild_id = guild_id
		self.channel_id = channel_id
		self.self_mute = self_mute
		self.self_deaf = self_deaf
		self.self_video = self_video
	}
    
    public func encode(to encoder: Encoder) throws {
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
public struct GatewayResume: OutgoingGatewayData {
    public let token: String
    public let session_id: String
    public let seq: Int // Last sequence number received
}

// MARK: Opcode 8 (Guild Request Members)
public struct GatewayGuildRequestMembers: GatewayData {
    public let guild_id: Snowflake
    public let query: String?
    public let limit: Int
    public let presences: Bool? // Used to specify if we want the presences of the matched members
    public let user_ids: [Snowflake]? // Used to specify which users you wish to fetch
    public let nonce: String? // Nonce to identify the Guild Members Chunk response
}

// MARK: Opcode 10 (Hello)
public struct GatewayHello: GatewayData {
    public let heartbeat_interval: Int
}

// MARK: Opcode 14 (Subscribe Guild Events)
public struct SubscribeGuildEvts: OutgoingGatewayData {
    public let guild_id: Snowflake
    public let typing: Bool
    public let activities: Bool
    public let threads: Bool

	public init(guild_id: Snowflake, typing: Bool = false, activities: Bool = false, threads: Bool = false) {
		self.guild_id = guild_id
		self.typing = typing
		self.activities = activities
		self.threads = threads
	}
}
