//
//  Application.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

struct Application: Codable {
    let id: Snowflake
    let name: String
    let icon: String? // Icon hash of app
    let description: String
    let rpc_origins: [String]? // An array of rpc origin urls, if rpc is enabled
    let bot_public: Bool // When false only app owner can join the app's bot to guilds
    let bot_require_code_grant: Bool // When true the app's bot will only join upon completion of the full oauth2 code grant flow
    let terms_of_service_url: String?
    let privacy_policy_url: String?
    let owner: User?
    let summary: String
    let verify_key: String
    let team: Team?
    let guild_id: Snowflake?
    let primary_sku_id: Snowflake?
    let slug: String?
    let cover_image: String? // The application's default rich presence invite cover image hash
    let flags: Int? // The application's public flags
}
