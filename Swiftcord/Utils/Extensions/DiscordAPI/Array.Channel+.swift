//
//  Array.Channel+.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import DiscordKitCore

extension Array where Element == Channel {
    func discordSorted() -> Self {
        sorted {
            // This is a DM/Group DM channel
            if $0.type == .dm || $0.type == .groupDM {
                return UInt64($0.last_message_id ?? $0.id) ?? 0 >
                    UInt64($1.last_message_id ?? $1.id) ?? 0
            }

            if $0.type == .voice, $1.type != .voice { return false }
            if $0.type != .voice, $1.type == .voice { return true }
            if let pos1 = $0.position, let pos2 = $1.position { return pos2 > pos1 }
            return $1.id > $0.id
        }
    }
}
