//
//  ChannelPinsUpdate.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

// Not sent when pinned message is deleted
public struct ChannelPinsUpdate: Codable, GatewayData {
    public let guild_id: Snowflake?
    public let channel_id: Snowflake
    public let last_pin_timestamp: ISOTimestamp?
}
