//
//  GetUserAvatarURL.swift
//  Native Discord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation

extension User {
    func avatarURL(size: Int = 160) -> URL {
        return URL(string: self.avatar != nil
            ? "\(apiConfig.cdnURL)avatars/\(self.id)/\(self.avatar!).webp?size=\(size)"
            : "\(apiConfig.cdnURL)embed/avatars/\((Int(self.discriminator) ?? 0) % 5).png"
        )!
    }
}
