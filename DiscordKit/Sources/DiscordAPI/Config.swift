//
//  Config.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 20/2/22.
//
//  Base config for many parts in Discord API

import Foundation

// Target official Discord client version for feature parity
public enum ClientReleaseChannel: String {
    case canary = "canary"
    case beta = "beta"
    case stable = "stable"
}
public struct ClientParityVersion {
    public let version: String
    public let buildNumber: Int
    public let releaseCh: ClientReleaseChannel
    public let electronVersion: String
}

public struct GatewayConfig {
	public let baseURL: String
	public let cdnURL: String
	public let version: Int
	public let parity: ClientParityVersion
    
	public let restBase: String
	public let gateway: String
    
	public init(
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

	public static let clientParity = ClientParityVersion(version: "0.0.283",
												  buildNumber: 115689,
												  releaseCh: .canary,
												  electronVersion: "13.6.6")
	public static let `default` = GatewayConfig(baseURL: "canary.discord.com",
										 version: 9,
										 clientParity: Self.clientParity)
}
