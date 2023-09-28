//
//  Snowflake+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 20/10/22.
//

import Foundation
import DiscordKitCore

extension Snowflake {
	static let DM_GUILD = "@me"

	var isDM: Bool { self == Self.DM_GUILD }
}

extension Snowflake {
	var createdAt: Date? {
		decodeToDate()
	}
}
