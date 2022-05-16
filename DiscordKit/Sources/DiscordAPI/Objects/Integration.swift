//
//  Integration.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

public enum IntegrationType: String, Codable {
    case youtube = "youtube"
    case twitch = "twitch"
    case discord = "discord"
}

public enum InteractionExpireBehaviour: Int, Codable {
    case removeRole = 0
    case kick = 1
}

public struct Integration: Codable, GatewayData {
    public let id: Snowflake
    public let name: String
    public let type: IntegrationType
    public let enabled: Bool
    public let syncing: Bool?
    public let role_id: Snowflake? // ID that this integration uses for "subscribers"
    public let enable_emoticons: Bool? // Twitch only, currently
    public let expire_behavior: InteractionExpireBehaviour?
    public let expire_grace_period: Int? // The grace period (in days) before expiring subscribers
    public let user: User?
    public let account: IntegrationAccount
    public let synced_at: ISOTimestamp?
    public let subscriber_count: Int?
    public let revoked: Bool?
    public let application: IntegrationApplication?
}

public struct IntegrationAccount: Codable, GatewayData {
    public let id: String
    public let name: String
}

public struct IntegrationApplication: Codable, GatewayData {
    public let id: Snowflake // ID of the app
    public let name: String
    public let icon: String?
    public let description: String
    public let summary: String
    public let bot: User? // The bot associated with this application
}
