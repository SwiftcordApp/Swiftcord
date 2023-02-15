//
//  GetUserAvatarURL.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation
import DiscordKitCore

extension User {
    func avatarURL(size: Int = 160) -> URL {
		if let avatar = avatar {
			return avatar.avatarURL(of: id, size: size)
		} else { return HashedAsset.defaultAvatar(of: discriminator) }
    }
}
