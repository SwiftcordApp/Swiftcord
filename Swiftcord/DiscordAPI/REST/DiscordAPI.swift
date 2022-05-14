//
//  DiscordRestAPI.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation
import os

struct DiscordAPI {
    static let log = Logger(category: "DiscordREST")
    // How empty, everything is broken into smaller files (for now xD)
    
    static var session: URLSession = {
        // Create URL Session Configuration
        let configuration = URLSessionConfiguration.default

        // Define Request Cache Policy (causes stale data sometimes)
        // configuration.requestCachePolicy = .returnCacheDataElseLoad

        return URLSession(configuration: configuration)
    }()
}
