//
//  Guild.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public enum GuildFeature: String, Codable {
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
    
public struct Guild: GatewayData, Equatable, Identifiable {
	public init(id: Snowflake, name: String, icon: String? = nil, icon_hash: String? = nil, splash: String? = nil, discovery_splash: String? = nil, owner: Bool? = nil, owner_id: Snowflake, permissions: String? = nil, region: String? = nil, afk_channel_id: Snowflake? = nil, afk_timeout: Int, widget_enabled: Bool? = nil, widget_channel_id: Snowflake? = nil, verification_level: VerificationLevel, default_message_notifications: MessageNotifLevel, explicit_content_filter: ExplicitContentFilterLevel, roles: [DecodableThrowable<Role>], emojis: [DecodableThrowable<Emoji>], features: [DecodableThrowable<GuildFeature>], mfa_level: MFALevel, application_id: Snowflake? = nil, system_channel_id: Snowflake? = nil, system_channel_flags: Int, rules_channel_id: Snowflake? = nil, joined_at: ISOTimestamp? = nil, large: Bool? = nil, unavailable: Bool? = nil, member_count: Int? = nil, voice_states: [VoiceState]? = nil, members: [Member]? = nil, channels: [Channel]? = nil, threads: [Channel]? = nil, presences: [PresenceUpdate]? = nil, max_presences: Int? = nil, max_members: Int? = nil, vanity_url_code: String? = nil, description: String? = nil, banner: String? = nil, premium_tier: PremiumLevel, premium_subscription_count: Int? = nil, preferred_locale: Locale, public_updates_channel_id: Snowflake? = nil, max_video_channel_users: Int? = nil, approximate_member_count: Int? = nil, approximate_presence_count: Int? = nil, welcome_screen: GuildWelcomeScreen? = nil, nsfw_level: NSFWLevel, stage_instances: [StageInstance]? = nil, stickers: [Sticker]? = nil, guild_scheduled_events: [GuildScheduledEvent]? = nil, premium_progress_bar_enabled: Bool) {
		self.id = id
		self.name = name
		self.icon = icon
		self.icon_hash = icon_hash
		self.splash = splash
		self.discovery_splash = discovery_splash
		self.owner = owner
		self.owner_id = owner_id
		self.permissions = permissions
		self.region = region
		self.afk_channel_id = afk_channel_id
		self.afk_timeout = afk_timeout
		self.widget_enabled = widget_enabled
		self.widget_channel_id = widget_channel_id
		self.verification_level = verification_level
		self.default_message_notifications = default_message_notifications
		self.explicit_content_filter = explicit_content_filter
		self.roles = roles
		self.emojis = emojis
		self.features = features
		self.mfa_level = mfa_level
		self.application_id = application_id
		self.system_channel_id = system_channel_id
		self.system_channel_flags = system_channel_flags
		self.rules_channel_id = rules_channel_id
		self.joined_at = joined_at
		self.large = large
		self.unavailable = unavailable
		self.member_count = member_count
		self.voice_states = voice_states
		self.members = members
		self.channels = channels
		self.threads = threads
		self.presences = presences
		self.max_presences = max_presences
		self.max_members = max_members
		self.vanity_url_code = vanity_url_code
		self.description = description
		self.banner = banner
		self.premium_tier = premium_tier
		self.premium_subscription_count = premium_subscription_count
		self.preferred_locale = preferred_locale
		self.public_updates_channel_id = public_updates_channel_id
		self.max_video_channel_users = max_video_channel_users
		self.approximate_member_count = approximate_member_count
		self.approximate_presence_count = approximate_presence_count
		self.welcome_screen = welcome_screen
		self.nsfw_level = nsfw_level
		self.stage_instances = stage_instances
		self.stickers = stickers
		self.guild_scheduled_events = guild_scheduled_events
		self.premium_progress_bar_enabled = premium_progress_bar_enabled
	}

    public static func == (lhs: Guild, rhs: Guild) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: Snowflake
    public let name: String
    public let icon: String? // Icon hash
    public let icon_hash: String? // Also icon hash
    public let splash: String? // Splash hash
    public let discovery_splash: String?
    public let owner: Bool? // If current user is owner of guild
    public let owner_id: Snowflake
    public let permissions: String?
    public let region: String? // Voice region id for the guild (deprecated)
    public let afk_channel_id: Snowflake?
    public let afk_timeout: Int
    public let widget_enabled: Bool?
    public let widget_channel_id: Snowflake?
    public let verification_level: VerificationLevel
    public let default_message_notifications: MessageNotifLevel
    public let explicit_content_filter: ExplicitContentFilterLevel
    public let roles: [DecodableThrowable<Role>]
    public let emojis: [DecodableThrowable<Emoji>]
    public let features: [DecodableThrowable<GuildFeature>]
    public let mfa_level: MFALevel
    public let application_id: Snowflake? // For bot-created guilds
    public let system_channel_id: Snowflake? // ID of channel for system-created messages
    public let system_channel_flags: Int
    public let rules_channel_id: Snowflake?
    public let joined_at: ISOTimestamp?
    public let large: Bool?
    public let unavailable: Bool? // If guild is unavailable due to an outage
    public let member_count: Int?
    public let voice_states: [VoiceState]?
    public let members: [Member]?
    public let channels: [Channel]?
    public let threads: [Channel]?
    public let presences: [PresenceUpdate]?
    public let max_presences: Int? // null is always returned, apart from the largest of guilds
    public let max_members: Int?
    public let vanity_url_code: String?
    public let description: String?
    public let banner: String? // Banner hash
    public let premium_tier: PremiumLevel
    public let premium_subscription_count: Int? // Number of server boosts
    public let preferred_locale: Locale // Defaults to en-US
    public let public_updates_channel_id: Snowflake?
    public let max_video_channel_users: Int?
    public let approximate_member_count: Int? // Approximate number of members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true
    public let approximate_presence_count: Int? // Approximate number of non-offline members in this guild, returned from the GET /guilds/<id> endpoint when with_counts is true
    public let welcome_screen: GuildWelcomeScreen?
    public let nsfw_level: NSFWLevel
    public let stage_instances: [StageInstance]?
    public let stickers: [Sticker]?
    public let guild_scheduled_events: [GuildScheduledEvent]?
    public let premium_progress_bar_enabled: Bool
}

// Partial Guild, returned when listing guilds
public struct PartialGuild: Codable, GatewayData {
    public let id: Snowflake
    public let name: String
    public let icon: String? // Icon hash
    public let owner: Bool // If current user is owner of guild
    public let permissions: String
    public let features: [String]
}

public struct MutualGuild: Codable, GatewayData {
    public let id: Snowflake
    public let nick: String?
}

public struct GuildUnavailable: Codable, GatewayData {
    public let id: Snowflake
    public let unavailable: Bool?
}

public struct GuildWelcomeScreen: Codable, GatewayData {
    public let description: String?
    public let welcome_channels: [GuildWelcomeScreenChannel]
}

public struct GuildWelcomeScreenChannel: Codable, GatewayData {
    public let channel_id: Snowflake
    public let description: String
    public let emoji_id: Snowflake? // The emoji id, if the emoji is custom
    public let emoji_name: String? // The emoji name if custom, the unicode character if standard, or null if no emoji is set
}

public enum GuildScheduledEvtPrivacyLvl: Int, Codable {
    case guild = 2
}
public enum GuildScheduledEvtStatus: Int, Codable {
    case scheduled = 1
    case active = 2
    case completed = 3
    case cancelled = 4
}
public enum GuildScheduledEvtEntityType: Int, Codable {
    case stageInstance = 1
    case voice = 2
    case external = 3
}

public struct GuildScheduledEvent: Codable, GatewayData {
    public let id: Snowflake
    public let guild_id: Snowflake
    public let channel_id: Snowflake?
    public let creator_id: Snowflake?
    public let name: String
    public let description: String?
    public let scheduled_start_time: ISOTimestamp
    public let scheduled_end_time: ISOTimestamp?
    public let privacy_level: GuildScheduledEvtPrivacyLvl
    public let status: GuildScheduledEvtStatus
    public let entity_type: GuildScheduledEvtEntityType
    public let entity_id: Snowflake?
    public let entity_metadata: GuildScheduledEventEntityMeta?
    public let creator: User?
    public let user_count: Int?
    public let image: String? // Cover image hash of event
}

public struct GuildScheduledEventEntityMeta: Codable, GatewayData {
    public let location: String?
}

// Guild folders sent in ready event
public struct GuildFolder: Decodable, GatewayData {
    public let name: String?
    // let id: Int? // Sometimes Discord sends over String snowflakes, but sometimes it sends int snowflakes instead just to make life hard
    public let guild_ids: [Snowflake]
    public let color: Int?
}
