//
//  Sticker.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public enum StickerType: Int, Codable {
    case standard = 1
    case guild = 2
}

public enum StickerFormat: Int, Codable {
    case png = 1
    case aPNG = 2 // Animated PNG
    case lottie = 3
}

public struct Sticker: Codable, GatewayData {
    public let id: Snowflake
    public let pack_id: Snowflake? // For standard stickers, id of the pack the sticker is from
    public let name: String
    public let description: String?
    public let tags: String // Autocomplete/suggestion tags for the sticker (max 200 characters), might be CSV
    public let asset: String?
    // Depreciated: now an empty string
    public let type: StickerType
    public let format_type: StickerFormat
    public let available: Bool? // Whether this guild sticker can be used, may be false due to loss of Server Boosts
    public let guild_id: Snowflake?
    public let user: User? // User that uploaded sticker
    public let sort_value: Int? // Sticker's sort order in its pack
}

public struct StickerItem: Codable, Identifiable {
    public let id: Snowflake
    public let name: String
    public let format_type: StickerFormat
}
