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
    case dispatchEvent = 0 // Event dispatched
    case heartbeat = 1
    case reconnect = 7 // Server is closing connection, should disconnect and resume
    case invalidSession = 9
    case hello = 10
    case heartbeatAck = 11
}

// MARK: - Main Gateway Sending/Receiving Structs

struct GatewayIncoming: Decodable {
    let op: GatewayIncomingOpcodes
    var d: GatewayData?
    let s: Int? // Sequence #
    let t: GatewayEvent?
    var primitiveData: Any?
    
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
        t = try values.decodeIfPresent(GatewayEvent.self, forKey: .t)
                
        switch action {
        case .hello: d = try values.decode(GatewayHello.self, forKey: .d)
        case .invalidSession: primitiveData = try values.decode(Bool.self, forKey: .d) // Parse data as bool
        case .dispatchEvent:
            // Cue the long switch case to parse every single event
            switch t {
            case .ready: d = try values.decode(ReadyEvt.self, forKey: .d)
            case .resumed: d = nil
            case .channelCreate, .channelUpdate, .channelDelete, .threadCreate, .threadUpdate, .threadDelete:
                d = try values.decode(Channel.self, forKey: .d)
            case .channelPinUpdate: d = try values.decode(ChannelPinsUpdate.self, forKey: .d)
                
            case .threadListSync: d = try values.decode(ThreadListSync.self, forKey: .d)
            case .threadMemberUpdate: d = try values.decode(ThreadMember.self, forKey: .d)
            case .threadMembersUpdate: d = try values.decode(ThreadMembersUpdate.self, forKey: .d)
                
            case .guildUpdate, .guildCreate: d = try values.decode(Guild.self, forKey: .d)
            case .guildDelete: d = try values.decode(GuildUnavailable.self, forKey: .d)
            case .guildBanAdd, .guildBanRemove: d = try values.decode(GuildBan.self, forKey: .d)
            case .guildEmojisUpdate: d = try values.decode(GuildEmojisUpdate.self, forKey: .d)
            case .guildStickersUpdate: d = try values.decode(GuildStickersUpdate.self, forKey: .d)
            case .guildIntegrationsUpdate: d = try values.decode(GuildIntegrationsUpdate.self, forKey: .d)
            case .guildMemberAdd: d = try values.decode(Member.self, forKey: .d)
            case .guildMemberRemove: d = try values.decode(GuildMemberRemove.self, forKey: .d)
            case .guildMemberUpdate: d = try values.decode(GuildMemberUpdate.self, forKey: .d)
            case .guildRoleCreate: d = try values.decode(GuildRoleEvt.self, forKey: .d)
            case .guildRoleUpdate: d = try values.decode(GuildRoleEvt.self, forKey: .d)
            case .guildRoleDelete: d = try values.decode(GuildRoleDelete.self, forKey: .d)
            case .guildSchEvtCreate, .guildSchEvtUpdate, .guildSchEvtDelete: d = try values.decode(GuildScheduledEvent.self, forKey: .d)
            case .guildSchEvtUserAdd, .guildSchEvtUserRemove: d = try values.decode(GuildSchEvtUserEvt.self, forKey: .d)
                
                // TODO: More events go here
            case .messageCreate: d = try values.decode(Message.self, forKey: .d)
            case .messageUpdate: d = try values.decode(PartialMessage.self, forKey: .d)
            case .messageDelete: d = try values.decode(MessageDelete.self, forKey: .d)
            case .messageDeleteBulk: d = try values.decode(MessageDeleteBulk.self, forKey: .d)
            case .presenceUpdate: d = try values.decode(PartialPresenceUpdate.self, forKey: .d)
                // TODO: Add the remaining like 100 events
                
            default: break
            }
        default:
            d = nil
        }
    }
}

struct GatewayOutgoing<T: OutgoingGatewayData>: Encodable {
    let op: GatewayOutgoingOpcodes
    let d: T?
    let s: Int? // Sequence #
}
