//
//  Guild+.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import DiscordKitCore

extension Guild {
	var isDMChannel: Bool { id == "@me" }
}
