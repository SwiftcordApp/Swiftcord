//
//  SubscribeGuildEvts.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 11/5/22.
//

import Foundation

struct SubscribeGuildEvts: OutgoingGatewayData {
    let guild_id: Snowflake
    var typing: Bool = false
    var activities: Bool = false
    var threads: Bool = false
}
