//
//  Channel+.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import DiscordKitCore

extension Channel {
	func label(_ users: [Snowflake: User] = [:]) -> String? {
		name ?? recipient_ids?
			.compactMap { users[$0]?.username }
			.joined(separator: ", ")
	}
}
