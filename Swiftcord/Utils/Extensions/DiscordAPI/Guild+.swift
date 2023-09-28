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

extension Guild {
	func iconURL(size: Int = 240) -> String? {
		icon != nil ? "\(DiscordKitConfig.default.cdnURL)icons/\(id)/\(icon!).webp?size=\(size)" : nil
	}
}
