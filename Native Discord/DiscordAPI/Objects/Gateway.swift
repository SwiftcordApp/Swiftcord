//
//  Gateway.swift
//  Native Discord
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

/*
 Contains structs to decode JSON sent back by Gateway. May not
 include a complete list of data structs for all opcodes/events,
 but enough for what this app needs to do.
 */

enum GatewayCloseCode: Int {
    case unknown = 4000
    case unknownOpcode = 4001
    case decodeErr = 4002
    case notAuthenthicated = 4003
    case authenthicationFail = 4004
    case alreadyAuthenthicated = 4005
    case invalidSeq = 4007
    case rateLimited = 4008
    case timedOut = 4009
    case invalidVersion = 4012
    case invalidIntent = 4013
    case disallowedIntent = 4014
}

// MARK: - Gateway Opcode enums
enum GatewayOutgoingOpcodes: Int, Codable {
    case heartbeat = 1
    case identify = 2
    case presenceUpdate = 3
    case voiceStateUpdate = 4
    case resume = 6 // Attempt to resume disconnected session
    case requestGuildMembers = 8
}

enum GatewayIncomingOpcodes: Int, Codable {
    case dispatch = 0 // Event dispatched
    case heartbeat = 1
    case reconnect = 7 // Server is closing connection, should disconnect and resume
    case invalidSession = 9
    case hello = 10
    case heartbeatAck = 11
}

// MARK: - Gateway Data Structs

protocol GatewayData: Codable {
}

struct GatewayConnProperties: GatewayData {
    let os: String
    let browser: String
    let release_channel: String?
    let client_version: String?
    let os_version: String?
    let os_arch: String?
    let system_locale: String?
}

// MARK: Opcode 1 (Heartbeat)
typealias GatewayHeartbeat = Int?

// MARK: Opcode 2 (Identify)
struct GatewayIdentify: GatewayData {
    let token: String
    let properties: GatewayConnProperties
    let compress: Bool?
    let large_threshold: Int? // Value between 50 and 250, total number of members where the gateway will stop sending offline members in the guild member list
    let shard: [Int]? // Array of two integers (shard_id, num_shards)
    let presence: GatewayPresenceUpdate?
    let capabilities: Int // Hardcode this to 253
}

// MARK: Opcode 3 (Presence Update)
struct GatewayPresenceUpdate: GatewayData {
    let since: Int // Unix time (in milliseconds) of when the client went idle, or null if the client is not idle
    let activities: [Activity]
    let status: String
    let afk: Bool
}

// MARK: Opcode 4 (Voice State Update)
struct GatewayVoiceStateUpdate: GatewayData {
    let guild_id: Snowflake
    let channel_id: Snowflake? // ID of the voice channel client wants to join (null if disconnecting)
    let self_mute: Bool
    let self_deaf: Bool
}

// MARK: Opcode 6 (Resume)
struct GatewayResume: GatewayData {
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

// MARK: - Main Gateway Sending/Receiving Structs

struct GatewayIncoming: Decodable {
    let op: GatewayIncomingOpcodes
    let d: GatewayData?
    let s: Int? // Sequence #
    let t: String?
    
    private enum CodingKeys: String, CodingKey {
        case op
        case d
        case s
        case t
   }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let action = try values.decode(GatewayIncomingOpcodes.self, forKey: .op)
        
        op = action
        s = try values.decodeIfPresent(Int.self, forKey: .s)
        t = try values.decodeIfPresent(String.self, forKey: .t)
        
        switch action {
        case .hello:
            d = try values.decode(GatewayHello.self, forKey: .d)
        default:
            d = nil
        }
    }
}

/*struct GatewayOutgoing: Encodable {
    let op: GatewayOutgoingOpcodes
    let d: Encodable
    let s: Int? // Sequence #
    let t: String?
}
*/
