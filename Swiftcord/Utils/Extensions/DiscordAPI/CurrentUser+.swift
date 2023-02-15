//
//  CurrentUser+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 30/5/22.
//

import Foundation
import DiscordKitCore

extension CurrentUser {
	func avatarURL(size: Int = 160) -> URL {
		if let avatar = avatar {
			return URL(string: "\(DiscordKitConfig.default.cdnURL)avatars/\(self.id)/\(avatar).webp?size=\(size)")!
		} else {
			return URL(string: "\(DiscordKitConfig.default.cdnURL)embed/avatars/\((Int(self.discriminator) ?? 0) % 5).png")!
		}
	}
}
