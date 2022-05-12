//
//  MessageACKEvent.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 11/5/22.
//

import Foundation

struct MessageACKEvt: Codable, GatewayData {
    let message_id: Snowflake
    let channel_id: Snowflake
    let version: Int
}
