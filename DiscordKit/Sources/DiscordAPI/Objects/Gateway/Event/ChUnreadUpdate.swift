//
//  ChUnreadUpdate.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 13/5/22.
//

import Foundation

public struct ChannelUnreadUpdateItem: Codable {
    public let last_message_id: Snowflake
    public let id: Snowflake // ID of channel
}

public struct ChannelUnreadUpdate: Codable, GatewayData {
    public let guild_id: Snowflake
    public let channel_unread_updates: [ChannelUnreadUpdateItem]
}
