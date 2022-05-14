//
//  Interaction.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

// TODO: Impliment other interaction structs

enum InteractionType: Int, Codable {
    case ping = 1
    case applicationCmd = 2
    case messageComponent = 3
    case applicationCmdAutocomplete = 4
    case modalSubmit = 5
}

struct MessageInteraction: Codable {
    let id: Snowflake
    let type: InteractionType
    let name: String
    let user: User
    let member: Member?
}
