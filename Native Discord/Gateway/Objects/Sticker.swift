//
//  Sticker.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

enum StickerFormat: Int, Codable {
    case png = 1
    case aPNG = 2 // Animated PNG
    case lottie = 3
}

struct StickerItem: Codable {
    let id: Snowflake
    let name: String
    let format_type: StickerFormat
}
