//
//  Channel+.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import DiscordKit

extension Channel {
	var label: String? {
		name ?? recipients?.map({ "\($0.username)#\($0.discriminator)" }).joined(separator: ", ") ?? String(describing: self.member)
	}
}
