//
//  Team.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public struct Team: Codable {
    public let icon: String?
    public let id: Snowflake
    public let members: [TeamMember]
    public let name: String
    public let owner_user_id: Snowflake
}

public enum MembershipState: Int, Codable {
    case invited = 1
    case accepted = 2
}

public struct TeamMember: Codable {
    public let membership_state: MembershipState
    public let permissions: [String] // Will always be ["*"]
    public let team_id: Snowflake
    public let user: User
}
