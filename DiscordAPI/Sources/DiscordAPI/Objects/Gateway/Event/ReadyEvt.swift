//
//  ReadyEvt.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

struct ReadyEvt: Codable, GatewayData {
    let v: Int
    let user: User
    let guilds: [GuildUnavailable]
    let session_id: String
    let shard: [Int]? // Included for inclusivity, will not be used
    let application: PartialApplication? // Discord doesn't send for clients
}
