//
//  DiscordRestAPI.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation
import os

public struct DiscordAPI {
	static let subsystem = "com.cryptoalgo.discordapi"

	static let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? Self.subsystem, category: "DiscordAPI")
    // How empty, everything is broken into smaller files (for now xD)
    
    static var session: URLSession = {
        // Create URL Session Configuration
        let configuration = URLSessionConfiguration.default

        // Define Request Cache Policy (causes stale data sometimes)
        // configuration.requestCachePolicy = .returnCacheDataElseLoad

        return URLSession(configuration: configuration)
    }()
}
