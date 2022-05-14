//
//  Guild.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

enum GuildFeature: String, Codable {
    case animatedIcon = "ANIMATED_ICON"
    case animatedBanner = "ANIMATED_BANNER"
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
    case threadsEnabled = "THREADS_ENABLED"
    case newThreads = "NEW_THREAD_PERMISSIONS"
    case privateThreads = "PRIVATE_THREADS"
    case roleIcons = "ROLE_ICONS"
    case thread7DayArchive = "SEVEN_DAY_THREAD_ARCHIVE"
    case thread3DayArchive = "THREE_DAY_THREAD_ARCHIVE"
    case ticketedEvents = "TICKETED_EVENTS_ENABLED"
    case vanityURL = "VANITY_URL"
    case verified = "VERIFIED"
    case highBitrateVoice = "VIP_REGIONS"
    case welcomeScreen = "WELCOME_SCREEN_ENABLED"
    case memberProfiles = "MEMBER_PROFILES"
    case discoverableBefore = "ENABLED_DISCOVERABLE_BEFORE"
}
    
struct Guild: GatewayData, Equatable, Identifiable {
    static func == (lhs: Guild, rhs: Guild) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Snowflake
    let name: String
    var icon: String? = nil // Icon hash
    var icon_hash: String? = nil // Also icon hash
    var splash: String? = nil // Splash hash
    var discovery_splash: String? = nil
    var owner: Bool? = nil // If current user is owner of guild
    let owner_id: Snowflake
    var permissions: String? = nil
    var region: String? = nil // Voice region id for the guild (deprecated)
    var afk_channel_id: Snowflake? = nil
    let afk_timeout: Int
    var widget_enabled: Bool? = nil
    var widget_channel_id: Snowflake? = nil
    let verification_level: VerificationLevel
    let default_message_notifications: MessageNotifLevel
    let explicit_content_filter: ExplicitContentFilterLevel
    let roles: [DecodableThrowable<Role>]
    let emojis: [DecodableThrowable<Emoji>]
    let features: [DecodableThrowable<GuildFeature>]
    let mfa_level: MFALevel
    var application_id: Snowflake? = nil // For bot-created guilds
    var system_channel_id: Snowflake? = nil // ID of channel for system-created messages
    let system_channel_flags: Int
    var rules_channel_id: Snowflake? = nil
    var joined_at: ISOTimestamp? = nil
    var large: Bool? = nil
    var unavailable: Bool? = nil // If guild is unavailable due to an outage
    var member_count: Int? = nil
    var voice_states: [VoiceState]? = nil
    var members: [Member]? = nil
    var channels: [Channel]? = nil
    var threads: [Channel]? = nil
    var presences: [PresenceUpdate]? = nil
    var max_presences: Int? = nil // null is always returned, apart from the largest of guilds
    var max_members: Int? = nil
    var vanity_url_code: String? = nil
    var description: String? = nil
    var banner: String? = nil // Banner hash
    let premium_tier: PremiumLevel
    var premium_subscription_count: Int? = nil // Number of server boosts
    let preferred_locale: Locale // Defaults to en-US
    var public_updates_channel_id: Snowflake? = nil
    var max_video_channel_users: Int? = nil
    var approximate_member_count: Int? = nil // Approximate number of members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true
    var approximate_presence_count: Int? = nil // Approximate number of non-offline members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true
    var welcome_screen: GuildWelcomeScreen? = nil
    let nsfw_level: NSFWLevel
    var stage_instances: [StageInstance]? = nil
    var stickers: [Sticker]? = nil
    var guild_scheduled_events: [GuildScheduledEvent]? = nil
    let premium_progress_bar_enabled: Bool
}

// Partial Guild, returned when listing guilds
struct PartialGuild: Codable, GatewayData {
    let id: Snowflake
    let name: String
    let icon: String? // Icon hash
    let owner: Bool // If current user is owner of guild
    let permissions: String
    let features: [String]
}

struct MutualGuild: Codable, GatewayData {
    let id: Snowflake
    let nick: String?
}

struct GuildUnavailable: Codable, GatewayData {
    let id: Snowflake
    let unavailable: Bool?
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

// Guild folders sent in ready event
struct GuildFolder: Decodable, GatewayData {
    let name: String?
    // let id: Int? // Sometimes Discord sends over String snowflakes, but sometimes it sends int snowflakes instead just to make life hard
    let guild_ids: [Snowflake]
    let color: Int?
}
