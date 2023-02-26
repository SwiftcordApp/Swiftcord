//
//  AccountMeta.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 3/9/22.
//

import Foundation
import DiscordKitCore

struct AccountMeta: Codable, Equatable, Identifiable {
	let id: Snowflake
	let discrim: String
	let name: String
	let avatar: URL

	init(id: Snowflake, discrim: String, name: String, avatar: URL) {
		self.id = id
		self.discrim = discrim
		self.name = name
		self.avatar = avatar
	}

	init(user: CurrentUser) {
		id = user.id
		discrim = user.discriminator
		name = user.username
		avatar = user.avatarURL(size: 80)
	}

	private enum CodingKeys: String, CodingKey {
		case discrim = "d", name = "n", avatar = "a", id = "i"
	}

	static func == (lhs: AccountMeta, rhs: AccountMeta) -> Bool { lhs.id == rhs.id }
}
