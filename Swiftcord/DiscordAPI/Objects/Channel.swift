//
//  Channel.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

enum VideoQualityMode: Int, Codable {
    case auto = 1 // Discord chooses quality for optimal performance
    case full = 2 // 720p
}

enum ChannelType: Int, Codable {
    case text = 0
    case dm = 1
    case voice = 2
    case groupDM = 3
    case category = 4
    case news = 5
    case store = 6 // Depreciated game-selling channel
    case newsThread = 10
    case publicThread = 11
    case privateThread = 12
    case stageVoice = 13
    case directory = 14 // Hubs
    case forum = 15 // (still in development) a channel that can only contain threads
}

struct Channel: Identifiable, Codable, GatewayData, Equatable {
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Snowflake
    let type: ChannelType
    let guild_id: Snowflake?
    let position: Int?
    let permission_overwrites: [PermOverwrite]?
    let name: String?
    let topic: String?
    let nsfw: Bool?
    let last_message_id: Snowflake? // The id of the last message sent in this channel (may not point to an existing or valid message)
    let bitrate: Int?
    let user_limit: Int?
    let rate_limit_per_user: Int?
    let recipients: [User]?
    let icon: String? // Icon hash of group DM
    let owner_id: Snowflake?
    let application_id: Snowflake?
    let parent_id: Snowflake? // ID of parent category (for channels) or parent channel (for threads)
    let last_pin_timestamp: ISOTimestamp?
    let rtc_region: String?
    let video_quality_mode: VideoQualityMode?
    let message_count: Int? // Approx. msg count in threads, stops counting at 50
    let member_count: Int? // Approx. member count in threads, stops counting at 50
    let thread_metadata: ThreadMeta?
    let member: ThreadMember? // Thread member object for the current user, if they have joined the thread, only included on certain API endpoints
    let default_auto_archive_duration: Int? // Default duration that the clients (not the API) will use for newly created threads, in minutes, to automatically archive the thread after recent activity, can be set to: 60, 1440, 4320, 10080
    let permissions: String? // Computed permissions for the invoking user in the channel, including overwrites, only included when part of the resolved data received on a slash command interaction
}

/*
 Structs for threads, which are reskinned channels that can be
 children of a channel, for small discussions and the like.
 */

struct ThreadMeta: Codable {
    let archived: Bool
    let auto_archive_duration: Int // Duration in minutes to automatically archive the thread after recent activity, can be set to: 60, 1440, 4320, 10080
    let archive_timestamp: ISOTimestamp
    let locked: Bool
    let invitable: Bool? // Only available in private threads
    let create_timestamp: ISOTimestamp? // Timestamp when the thread was created; only populated for threads created after 2022-01-09
}

struct ThreadMember: Codable, GatewayData {
    let id: Snowflake? // ID of thread
    let user_id: Snowflake? // ID of user
    let join_timestamp: ISOTimestamp // When user last joined thread
    let flags: Int // Any user-thread settings, currently only used for notifications
    let guild_id: Snowflake?
}
