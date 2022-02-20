//
//  Reaction.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

struct Reaction: Codable {
    let count: Int
    let me: Bool
    let emoji: Emoji
}
