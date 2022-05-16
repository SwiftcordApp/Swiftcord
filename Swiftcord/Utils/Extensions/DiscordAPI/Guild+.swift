//
//  Guild+.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import DiscordAPI

extension Guild {
	var isDMChannel: Bool { id == "@me" }
}
