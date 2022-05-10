//
//  FilterSortChannels.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 10/5/22.
//

import Foundation

func filterAndSortChannels(_ chs: [Channel], _ filter: (Channel) -> Bool) -> [Channel] {
    return chs
        .sorted { c1, c2 in
            if c1.type == .voice, c2.type != .voice { return false }
            if c1.type != .voice, c2.type == .voice { return true }
            if c1.position != nil, c2.position != nil { return c2.position! > c1.position! }
            return c2.id > c1.id
        }
        .filter(filter)
}
