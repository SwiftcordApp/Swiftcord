//
//  Team.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

struct Team: Codable {
    let icon: String?
    let id: Snowflake
    let members: [TeamMember]
    let name: String
    let owner_user_id: Snowflake
}

enum MembershipState: Int, Codable {
    case invited = 1
    case accepted = 2
}

struct TeamMember: Codable {
    let membership_state: MembershipState
    let permissions: [String] // Will always be ["*"]
    let team_id: Snowflake
    let user: User
}
