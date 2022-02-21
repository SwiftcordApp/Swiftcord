//
//  Guild.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

enum GuildFeature: String, Codable {
    case animatedIcon = "ANIMATED_ICON"
    case banner = "BANNER"
    case commerce = "COMMERCE"
    case community = "COMMUNITY"
    case discoverable = "DISCOVERABLE"
    case featurable = "FEATURABLE"
    case inviteSplash = "INVITE_SPLASH"
    case membershipScreening = "MEMBER_VERIFICATION_GATE_ENABLED"
    case monetization = "MONETIZATION_ENABLED"
    case moreStickers = "MORE_STICKERS"
    case news = "NEWS"
    case partnered = "PARTNERED"
    case previewEnabled = "PREVIEW_ENABLED"
    case privateThreads = "PRIVATE_THREADS"
    case roleIcons = "ROLE_ICINS"
    case thread7DayArchive = "SEVEN_DAY_THREAD_ARCHIVE"
    case thread3DayArchive = "THREE_DAY_THREAD_ARCHIVE"
    case ticketedEvents = "TICKETED_EVENTS_ENABLED"
    case vanityURL = "VANITY_URL"
    case verified = "VERIFIED"
    case highBitrateVoice = "VIP_REGIONS"
    case welcomeScreen = "WELCOME_SCREEN_ENABLED"
}

struct Guild: Codable, GatewayData {
    let id: Snowflake
    let name: String
    let icon: String? // Icon hash
    let icon_hash: String? // Also icon hash
    let splash: String? // Splash hash
    let discovery_splash: String?
    let owner: Bool? // If current user is owner of guild
    let owner_id: Snowflake
    let permissions: String?
    let region: String? // Voice region id for the guild (deprecated)
    let afk_channel_id: Snowflake?
    let afk_timeout: Int
    let widget_enabled: Bool?
    let widget_channel_id: Snowflake?
    let verification_level: VerificationLevel
    let default_message_notifications: MessageNotifLevel
    let explicit_content_filter: ExplicitContentFilterLevel
    let roles: [Role]
    let emojis: [Emoji]
    let features: [GuildFeature]
    let mfa_level: MFALevel
    let application_id: Snowflake? // For bot-created guilds
    let system_channel_id: Snowflake? // ID of channel for system-created messages
    let system_channel_flags: Int
    let rules_channel_id: Snowflake?
    let joined_at: ISOTimestamp?
    let large: Bool?
    let unavailable: Bool? // If guild is unavailable due to an outage
    let member_count: Int?
    let voice_states: [VoiceState]?
    let members: [Member]?
    let channels: [Channel]?
    let threads: [Channel]?
    let presences: [PresenceUpdate]?
    let max_presences: Int? // null is always returned, apart from the largest of guilds
    let max_members: Int?
    let vanity_url_code: String?
    let description: String?
    let banner: String? // Banner hash
    let premium_tier: PremiumLevel
    let premium_subscription_count: Int? // Number of server boosts
    let preferred_locale: Locale // Defaults to en-US
    let public_updates_channel_id: Snowflake?
    let max_video_channel_users: Int?
    let approximate_member_count: Int? // Approximate number of members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true
    let approximate_presence_count: Int? // Approximate number of non-offline members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true
    let welcome_screen: GuildWelcomeScreen?
    let nsfw_level: NSFWLevel
    let stage_instances: [StageInstance]?
    let stickers: [Sticker]?
    let guild_scheduled_events: [GuildScheduledEvent]?
    let premium_progress_bar_enabled: Bool
}

struct GuildUnavailable: Codable, GatewayData {
    let id: Snowflake
    let unavailable: Bool? // If not set, user was removed from guild
}

struct GuildWelcomeScreen: Codable, GatewayData {
    let description: String?
    let welcome_channels: [GuildWelcomeScreenChannel]
}

struct GuildWelcomeScreenChannel: Codable, GatewayData {
    let channel_id: Snowflake
    let description: String
    let emoji_id: Snowflake? // The emoji id, if the emoji is custom
    let emoji_name: String? // The emoji name if custom, the unicode character if standard, or null if no emoji is set
}

enum GuildScheduledEvtPrivacyLvl: Int, Codable {
    case guild = 2
}
enum GuildScheduledEvtStatus: Int, Codable {
    case scheduled = 1
    case active = 2
    case completed = 3
    case cancelled = 4
}
enum GuildScheduledEvtEntityType: Int, Codable {
    case stageInstance = 1
    case voice = 2
    case external = 3
}

struct GuildScheduledEvent: Codable, GatewayData {
    let id: Snowflake
    let guild_id: Snowflake
    let channel_id: Snowflake?
    let creator_id: Snowflake?
    let name: String
    let description: String?
    let scheduled_start_time: ISOTimestamp
    let scheduled_end_time: ISOTimestamp?
    let privacy_level: GuildScheduledEvtPrivacyLvl
    let status: GuildScheduledEvtStatus
    let entity_type: GuildScheduledEvtEntityType
    let entity_id: Snowflake?
    let entity_metadata: GuildScheduledEventEntityMeta?
    let creator: User?
    let user_count: Int?
    let image: String? // Cover image hash of event
}

struct GuildScheduledEventEntityMeta: Codable, GatewayData {
    let location: String?
}
