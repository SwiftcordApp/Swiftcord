//
//  MessageDeleteEvents.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct MessageDeleteEventData: Codable, GatewayData {
	public let id: Snowflake
	public let channel_id: Snowflake
	public let guild_id: Snowflake?
}

public struct MessageDeleteBulkEventData: Codable, GatewayData {
	public let id: [Snowflake]
	public let channel_id: Snowflake
	public let guild_id: Snowflake?
}
