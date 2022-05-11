//
//  CachedState.swift
//  Native Discord
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

struct CachedState {
    var guilds: [Guild]?
    var dms: [Channel]?
    var user: User?
    var users: [User]? // Cached users, grows over time
}
