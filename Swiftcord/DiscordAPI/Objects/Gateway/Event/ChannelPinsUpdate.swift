//
//  ChannelPinsUpdate.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

// Not sent when pinned message is deleted
struct ChannelPinsUpdate: Codable, GatewayData {
    let guild_id: Snowflake?
    let channel_id: Snowflake
    let last_pin_timestamp: ISOTimestamp?
}
