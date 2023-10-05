//
//  User+displayName.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/10/23.
//

import Foundation
import DiscordKitCore

extension User {
	var displayName: String {
		global_name ?? username
	}
}
