//
//  Guild+.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import DiscordKitCommon

extension Guild {
	var isDMChannel: Bool { id == "@me" }
}
