//
//  Config.swift
//  Native Discord
//
//  Created by Vincent Kwok on 20/2/22.
//
//  Base config for many parts in Discord API

import Foundation

struct GatewayConfig {
    let baseURL: String
    let version: Int
    
    let restBase: String
    let gateway: String
    
    init(baseURL: String, version: Int) {
        self.baseURL = "https://\(baseURL)"
        self.version = version
        gateway = "wss://gateway.discord.gg/?v=\(version)&encoding=json"
        restBase = "\(self.baseURL)/api/v\(version)/"
    }
}

let apiConfig = GatewayConfig(baseURL: "canary.discord.com", version: 9)
