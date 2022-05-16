//
//  CachedState.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

public struct CachedState {
	public var guilds: [Guild]?
	public var dms: [Channel]?
	public var user: User?
	public var users: [User]? // Cached users, grows over time
}
