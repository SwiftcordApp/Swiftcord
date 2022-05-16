//
//  ReadyEvt.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct ReadyEvt: Decodable, GatewayData {
    public let v: Int
    public let user: User
    public let users: [User]
    public let guilds: [Guild]
    public let session_id: String
    public let shard: [Int]? // Included for inclusivity, will not be used
    public let application: PartialApplication? // Discord doesn't send this to human clients
    public let user_settings: UserSettings
    public let private_channels: [Channel] // Basically DMs
}
