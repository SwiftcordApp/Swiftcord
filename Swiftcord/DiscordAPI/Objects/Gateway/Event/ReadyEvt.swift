//
//  ReadyEvt.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

struct ReadyEvt: Decodable, GatewayData {
    let v: Int
    let user: User
    let users: [User]
    let guilds: [Guild]
    let session_id: String
    let shard: [Int]? // Included for inclusivity, will not be used
    let application: PartialApplication? // Discord doesn't send this to human clients
    let user_settings: UserSettings
    let private_channels: [Channel] // Basically DMs
}
