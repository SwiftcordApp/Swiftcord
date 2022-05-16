//
//  Voice.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

struct VoiceState: Codable, GatewayData {
    let guild_id: Snowflake?
    let channel_id: Snowflake?
    let user_id: Snowflake
    let member: Member?
    let session_id: String
    let deaf: Bool // Deafened by server
    let mute: Bool
    let self_deaf: Bool
    let self_mute: Bool
    let self_stream: Bool?
    let self_video: Bool
    let suppress: Bool
    let request_to_speak_timestamp: ISOTimestamp? // Time when user requested to speak, if any
}
