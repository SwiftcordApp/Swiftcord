//
//  Config.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 20/2/22.
//
//  Base config for many parts in Discord API

import Foundation

// Target official Discord client version for feature parity
enum ClientReleaseChannel: String {
    case canary = "canary"
    case beta = "beta"
    case stable = "stable"
}
struct ClientParityVersion {
    let version: String
    let buildNumber: Int
    let releaseCh: ClientReleaseChannel
    let electronVersion: String
}

struct GatewayConfig {
    let baseURL: String
    let cdnURL: String
    let version: Int
    let parity: ClientParityVersion
    
    let restBase: String
    let gateway: String
    
    init(
        baseURL: String,
        version: Int,
        clientParity: ClientParityVersion
    ) {
        self.cdnURL = "https://cdn.discordapp.com/"
        self.baseURL = "https://\(baseURL)/"
        self.version = version
        parity = clientParity
        gateway = "wss://gateway.discord.gg/?v=\(version)&encoding=json&compress=zlib-stream"
        restBase = "\(self.baseURL)api/v\(version)/"
    }
}

let apiConfig = GatewayConfig(
    baseURL: "canary.discord.com",
    version: 9,
    clientParity: ClientParityVersion(
        version: "0.0.283",
        buildNumber: 115689,
        releaseCh: .canary,
        electronVersion: "13.6.6"
    )
)
