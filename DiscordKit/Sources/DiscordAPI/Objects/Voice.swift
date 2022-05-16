//
//  Voice.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public struct VoiceState: Codable, GatewayData {
    public let guild_id: Snowflake?
    public let channel_id: Snowflake?
    public let user_id: Snowflake
    public let member: Member?
    public let session_id: String
    public let deaf: Bool // Deafened by server
    public let mute: Bool
    public let self_deaf: Bool
    public let self_mute: Bool
    public let self_stream: Bool?
    public let self_video: Bool
    public let suppress: Bool
    public let request_to_speak_timestamp: ISOTimestamp? // Time when user requested to speak, if any
}
