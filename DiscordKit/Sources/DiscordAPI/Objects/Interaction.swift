//
//  Interaction.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

// TODO: Impliment other interaction structs

public enum InteractionType: Int, Codable {
    case ping = 1
    case applicationCmd = 2
    case messageComponent = 3
    case applicationCmdAutocomplete = 4
    case modalSubmit = 5
}

public struct MessageInteraction: Codable {
    public let id: Snowflake
    public let type: InteractionType
    public let name: String
    public let user: User
    public let member: Member?
}
