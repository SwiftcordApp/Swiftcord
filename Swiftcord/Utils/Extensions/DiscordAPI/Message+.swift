//
//  Message+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation
import DiscordKit

extension Message {
    func messageIsShrunk(prev: Message) -> Bool {
        return prev.author.id == self.author.id
        && (prev.type == .defaultMsg || prev.type == .reply)
        && self.type == .defaultMsg
        && (((self.timestamp.toDate() ?? Date()) - (prev.timestamp.toDate() ?? Date())) < 400)
    }
}
