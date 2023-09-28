//
//  Permissions+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 11/5/23.
//

import Foundation
import DiscordKitCore

public extension Permissions {
	static let all: Permissions = .init(rawValue: 0x7FFFFFFFFFFF)

	mutating func applyOverwrite(_ overwrite: PermOverwrite) {
		remove(overwrite.deny)
		formUnion(overwrite.allow)
	}
}
