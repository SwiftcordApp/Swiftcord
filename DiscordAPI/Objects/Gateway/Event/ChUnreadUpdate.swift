//
//  ChUnreadUpdate.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 13/5/22.
//

import Foundation

struct ChannelUnreadUpdateItem: Codable {
    let last_message_id: Snowflake
    let id: Snowflake // ID of channel
}

struct ChannelUnreadUpdate: Codable, GatewayData {
    let guild_id: Snowflake
    let channel_unread_updates: [ChannelUnreadUpdateItem]
}
