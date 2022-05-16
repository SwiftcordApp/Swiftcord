//
//  MessageACKEvent.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 11/5/22.
//

import Foundation

public struct MessageACKEvt: Codable, GatewayData {
    public let message_id: Snowflake
    public let channel_id: Snowflake
    public let version: Int
}
