//
//  Array.Channel+.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import DiscordKit

extension Array where Element == Channel {
	func discordSorted() -> Self {
		sorted { c1, c2 in
			if c1.type == .voice, c2.type != .voice { return false }
			if c1.type != .voice, c2.type == .voice { return true }
			if c1.position != nil, c2.position != nil { return c2.position! > c1.position! }
			return c2.id > c1.id
		}
	}
}
