//
//  Sticker.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

enum StickerType: Int, Codable {
    case standard = 1
    case guild = 2
}

enum StickerFormat: Int, Codable {
    case png = 1
    case aPNG = 2 // Animated PNG
    case lottie = 3
}

struct Sticker: Codable, GatewayData {
    let id: Snowflake
    let pack_id: Snowflake? // For standard stickers, id of the pack the sticker is from
    let name: String
    let description: String?
    let tags: String // Autocomplete/suggestion tags for the sticker (max 200 characters), might be CSV
    let asset: String?
    // Depreciated: now an empty string
    let type: StickerType
    let format_type: StickerFormat
    let available: Bool? // Whether this guild sticker can be used, may be false due to loss of Server Boosts
    let guild_id: Snowflake?
    let user: User? // User that uploaded sticker
    let sort_value: Int? // Sticker's sort order in its pack
}

struct StickerItem: Codable, Identifiable {
    let id: Snowflake
    let name: String
    let format_type: StickerFormat
}
