//
//  GetUserAvatarURL.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation

extension User {
    func avatarURL(size: Int = 160) -> URL {
		if let avatar = avatar {
			return URL(string: "\(apiConfig.cdnURL)avatars/\(self.id)/\(avatar).webp?size=\(size)")!
		} else {
			return URL(string: "\(apiConfig.cdnURL)embed/avatars/\((Int(self.discriminator) ?? 0) % 5).png")!
		}
    }
}
