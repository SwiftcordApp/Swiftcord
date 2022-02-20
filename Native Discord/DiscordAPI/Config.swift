//
//  Config.swift
//  Native Discord
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation

struct GatewayConfig {
    let baseURL: String
    let version: Int
    
    let restBase: String
    let gateway: String
    
    init(baseURL: String, version: Int) {
        self.baseURL = baseURL
        self.version = version
        gateway = "wss://gateway.discord.gg/?v=\(version)&encoding=json"
        restBase = "https://\(baseURL)/api/v\(version)/"
    }
}

let gatewayCfg = GatewayConfig(baseURL: "canary.discord.com", version: 9)
