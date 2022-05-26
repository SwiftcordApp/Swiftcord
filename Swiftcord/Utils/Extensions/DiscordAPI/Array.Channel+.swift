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
			// This is a DM/Group DM channel
			if c1.type == .dm || c1.type == .groupDM {
				return c1.last_message_id ?? c1.id > c2.last_message_id ?? c2.id
		    }
			
			if c1.type == .voice, c2.type != .voice { return false }
			if c1.type != .voice, c2.type == .voice { return true }
			if let p1 = c1.position, let p2 = c2.position { return p2 > p1 }
			return c2.id > c1.id
		}
	}
}
