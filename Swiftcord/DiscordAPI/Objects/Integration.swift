//
//  Integration.swift
//  Native Discord
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

enum IntegrationType: String, Codable {
    case youtube = "youtube"
    case twitch = "twitch"
    case discord = "discord"
}

enum InteractionExpireBehaviour: Int, Codable {
    case removeRole = 0
    case kick = 1
}

struct Integration: Codable, GatewayData {
    let id: Snowflake
    let name: String
    let type: IntegrationType
    let enabled: Bool
    let syncing: Bool?
    let role_id: Snowflake? // ID that this integration uses for "subscribers"
    let enable_emoticons: Bool? // Twitch only, currently
    let expire_behavior: InteractionExpireBehaviour?
    let expire_grace_period: Int? // The grace period (in days) before expiring subscribers
    let user: User?
    let account: IntegrationAccount
    let synced_at: ISOTimestamp?
    let subscriber_count: Int?
    let revoked: Bool?
    let application: IntegrationApplication?
}

struct IntegrationAccount: Codable, GatewayData {
    let id: String
    let name: String
}

struct IntegrationApplication: Codable, GatewayData {
    let id: Snowflake // ID of the app
    let name: String
    let icon: String?
    let description: String
    let summary: String
    let bot: User? // The bot associated with this application
}
