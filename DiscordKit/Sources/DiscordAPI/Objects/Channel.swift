//
//  Channel.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public enum VideoQualityMode: Int, Codable {
    case auto = 1 // Discord chooses quality for optimal performance
    case full = 2 // 720p
}

public enum ChannelType: Int, Codable {
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

public struct Channel: Identifiable, Codable, GatewayData, Equatable {
    public static func == (lhs: Channel, rhs: Channel) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: Snowflake
    public let type: ChannelType
    public let guild_id: Snowflake?
    public let position: Int?
    public let permission_overwrites: [PermOverwrite]?
    public let name: String?
    public let topic: String?
    public let nsfw: Bool?
    public let last_message_id: Snowflake? // The id of the last message sent in this channel (may not point to an existing or valid message)
    public let bitrate: Int?
    public let user_limit: Int?
    public let rate_limit_per_user: Int?
    public let recipients: [User]?
    public let icon: String? // Icon hash of group DM
    public let owner_id: Snowflake?
    public let application_id: Snowflake?
    public let parent_id: Snowflake? // ID of parent category (for channels) or parent channel (for threads)
    public let last_pin_timestamp: ISOTimestamp?
    public let rtc_region: String?
    public let video_quality_mode: VideoQualityMode?
    public let message_count: Int? // Approx. msg count in threads, stops counting at 50
    public let member_count: Int? // Approx. member count in threads, stops counting at 50
    public let thread_metadata: ThreadMeta?
    public let member: ThreadMember? // Thread member object for the current user, if they have joined the thread, only included on certain API endpoints
    public let default_auto_archive_duration: Int? // Default duration that the clients (not the API) will use for newly created threads, in minutes, to automatically archive the thread after recent activity, can be set to: 60, 1440, 4320, 10080
    public let permissions: String? // Computed permissions for the invoking user in the channel, including overwrites, only included when part of the resolved data received on a slash command interaction
}

/*
 Structs for threads, which are reskinned channels that can be
 children of a channel, for small discussions and the like.
 */

public struct ThreadMeta: Codable {
    public let archived: Bool
    public let auto_archive_duration: Int // Duration in minutes to automatically archive the thread after recent activity, can be set to: 60, 1440, 4320, 10080
    public let archive_timestamp: ISOTimestamp
    public let locked: Bool
    public let invitable: Bool? // Only available in private threads
    public let create_timestamp: ISOTimestamp? // Timestamp when the thread was created; only populated for threads created after 2022-01-09
}

public struct ThreadMember: Codable, GatewayData {
    public let id: Snowflake? // ID of thread
    public let user_id: Snowflake? // ID of user
    public let join_timestamp: ISOTimestamp // When user last joined thread
    public let flags: Int // Any user-thread settings, currently only used for notifications
    public let guild_id: Snowflake?
}
