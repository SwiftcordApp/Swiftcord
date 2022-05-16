//
//  GuildBanEvent.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct GuildBanEventData: Codable, GatewayData {
	public let guild_id: Snowflake
	public let user: User
}
