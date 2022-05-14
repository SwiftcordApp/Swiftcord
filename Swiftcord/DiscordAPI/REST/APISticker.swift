//
//  APISticker.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 24/2/22.
//

import Foundation

extension DiscordAPI {
    // MARK: Get Sticker
    // GET /stickers/{sticker.id}
    static func getSticker(id: Snowflake) async -> Sticker? {
        return await getReq(path: "stickers/\(id)")
    }
}
