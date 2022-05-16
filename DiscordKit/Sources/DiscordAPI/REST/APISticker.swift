//
//  APISticker.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 24/2/22.
//

import Foundation

public extension DiscordAPI {
    // MARK: Get Sticker
    // GET /stickers/{sticker.id}
    static func getSticker(id: Snowflake) async -> Sticker? {
        return await getReq(path: "stickers/\(id)")
    }
}
