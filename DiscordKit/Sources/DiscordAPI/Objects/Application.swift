//
//  Application.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public struct Application: Codable {
    public let id: Snowflake
    public let name: String
    public let icon: String? // Icon hash of app
    public let description: String
    public let rpc_origins: [String]? // An array of rpc origin urls, if rpc is enabled
    public let bot_public: Bool // When false only app owner can join the app's bot to guilds
    public let bot_require_code_grant: Bool // When true the app's bot will only join upon completion of the full oauth2 code grant flow
    public let terms_of_service_url: String?
    public let privacy_policy_url: String?
    public let owner: User?
    public let summary: String
    public let verify_key: String
    public let team: Team?
    public let guild_id: Snowflake?
    public let primary_sku_id: Snowflake?
    public let slug: String?
    public let cover_image: String? // The application's default rich presence invite cover image hash
    public let flags: Int? // The application's public flags
}
