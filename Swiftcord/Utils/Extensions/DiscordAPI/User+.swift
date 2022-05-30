//
//  GetUserAvatarURL.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation
import DiscordKit

extension User {
    func avatarURL(size: Int = 160) -> URL {
		if let avatar = avatar {
			return URL(string: "\(GatewayConfig.default.cdnURL)avatars/\(self.id)/\(avatar).webp?size=\(size)")!
		} else {
			return URL(string: "\(GatewayConfig.default.cdnURL)embed/avatars/\((Int(self.discriminator) ?? 0) % 5).png")!
		}
    }

	init(from user: CurrentUser) {
		self.init(
			id: user.id,
			username: user.username,
			discriminator: user.discriminator,
			avatar: user.avatar,
			bot: false,
			bio: user.bio,
			system: false,
			mfa_enabled: user.mfa_enabled,
			banner: user.banner,
			accent_color: user.accent_color,
			locale: nil,
			verified: nil,
			flags: user.flags,
			premium_type: user.purchased_flags,
			public_flags: user.public_flags
		)
	}
}
