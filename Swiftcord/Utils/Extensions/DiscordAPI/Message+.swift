//
//  Message+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation
import DiscordKitCore

extension Message {
    func messageIsShrunk(prev: Message) -> Bool {
        prev.author.id == self.author.id
            && (prev.type == .defaultMsg || prev.type == .reply)
            && self.type == .defaultMsg
            && (self.timestamp.timeIntervalSince(prev.timestamp) < 400)
    }
}
