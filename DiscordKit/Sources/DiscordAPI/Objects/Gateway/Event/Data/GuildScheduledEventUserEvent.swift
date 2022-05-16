//
//  GuildScheduledEventUserEvent.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct GuildScheduledEventUserEventData: Codable, GatewayData {
	public let guild_scheduled_event_id: Snowflake
	public let user_id: Snowflake
	public let guild_id: Snowflake
}
