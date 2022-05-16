//
//  Events.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

// Basically just one long enum

public enum GatewayEvent: String, Codable {
    // MARK: Gateway WebSocket Lifecycle
    case ready = "READY"
    case resumed = "RESUMED" // End of events replay
    
    // MARK: Channels
    case channelCreate = "CHANNEL_CREATE"
    case channelUpdate = "CHANNEL_UPDATE"
    case channelDelete = "CHANNEL_DELETE"
    case channelPinUpdate = "CHANNEL_PIN_UPDATE"
    
    // MARK: Threads
    case threadCreate = "THREAD_CREATE"
    case threadUpdate = "THREAD_UPDATE"
    case threadDelete = "THREAD_DELETE"
    case threadListSync = "THREAD_LIST_SYNC" // Sent when gaining access to a channel, contains all active threads in that channel
    case threadMemberUpdate = "THREAD_MEMBER_UPDATE" // Thread member for the current user was updated
    case threadMembersUpdate = "THREAD_MEMBERS_UPDATE"
    
    // MARK: - Guilds
    case guildCreate = "GUILD_CREATE"
    case guildUpdate = "GUILD_UPDATE"
    case guildDelete = "GUILD_DELETE"
    case guildBanAdd = "GUILD_BAN_ADD"
    case guildBanRemove = "GUILD_BAN_REMOVE"
    case guildEmojisUpdate = "GUILD_EMOJIS_UPDATE"
    case guildStickersUpdate = "GUILD_STICKERS_UPDATE"
    case guildIntegrationsUpdate = "GUILD_INTEGRATIONS_UPDATE"
    // MARK: Guild Members
    case guildMemberAdd = "GUILD_MEMBER_ADD"
    case guildMemberRemove = "GUILD_MEMBER_REMOVE"
    case guildMemberUpdate = "GUILD_MEMBER_UPDATE"
    case guildMembersChunk = "GUILD_MEMBERS_CHUNK"
    // MARK: Guild Roles
    case guildRoleCreate = "GUILD_ROLE_CREATE"
    case guildRoleUpdate = "GUILD_ROLE_UPDATE"
    case guildRoleDelete = "GUILD_ROLE_DELETE"
    // MARK: Guild scheduled events
    case guildSchEvtCreate = "GUILD_SCHEDULED_EVENT_CREATE"
    case guildSchEvtUpdate = "GUILD_SCHEDULED_EVENT_UPDATE"
    case guildSchEvtDelete = "GUILD_SCHEDULED_EVENT_DELETE"
    case guildSchEvtUserAdd = "GUILD_SCHEDULED_EVENT_USER_ADD"
    case guildSchEvtUserRemove = "GUILD_SCHEDULED_EVENT_USER_REMOVE"
    
    // MARK: Integrations
    case integrationCreate = "INTEGRATION_CREATE"
    case integrationUpdate = "INTEGRATION_UPDATE"
    case integrationDelete = "INTEGRATION_DELETE"
    
    // MARK: Interaction
    case interactionCreate = "INTERACTION_CREATE"
    
    // MARK: Invites
    case inviteCreate = "INVITE_CREATE"
    case inviteDelete = "INVITE_DELETE"
    
    // MARK: - Messages
    case messageCreate = "MESSAGE_CREATE"
    case messageUpdate = "MESSAGE_UPDATE"
    case messageDelete = "MESSAGE_DELETE"
    case messageACK = "MESSAGE_ACK" // When messages have been read
    case messageDeleteBulk = "MESSAGE_DELETE_BULK"
    // MARK: Message Reactions
    case messageReactAdd = "MESSAGE_REACTION_ADD"
    case messageReactRemove = "MESSAGE_REACTION_REMOVE"
    case messageReactRemoveAll = "MESSAGE_REACTION_REMOVE_ALL"
    case messageReactRemoveEmoji = "MESSAGE_REACTION_REMOVE_EMOJI"
    
    // MARK: Presence Update
    case presenceUpdate = "PRESENCE_UPDATE"
    
    // MARK: Stages
    case stageInstanceCreate = "STAGE_INSTANCE_CREATE"
    case stageInstanceDelete = "STAGE_INSTANCE_DELETE"
    case stageInstanceUpdate = "STAGE_INSTANCE_UPDATE"
    
    // MARK: Typing
    case typingStart = "TYPING_START"
    
    // MARK: Misc Updates
    case userUpdate = "USER_UPDATE"
    case voiceStateUpdate = "VOICE_STATE_UPDATE"
    case voiceServerUpdate = "VOICE_SERVER_UPDATE"
    case webhooksUpdate = "WEBHOOKS_UPDATE"
    
    // MARK: Human account-specific Events
    case channelUnreadUpdate = "CHANNEL_UNREAD_UPDATE"
}
