//
//  Identify.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation
import DiscordKitCommon

public extension RobustWebSocket {
    func getIdentify() -> GatewayIdentify? {
        // Keychain.save(key: "token", data: "token goes here")
        // Keychain.remove(key: "token") // For testing
        guard let token: String = Keychain.load(key: "authToken")
        else { return nil }
            
        return GatewayIdentify(
            token: token,
			properties: DiscordAPI.getSuperProperties(),
            compress: false,
            large_threshold: nil,
            shard: nil,
            presence: nil,
            capabilities: 0b11111101 // TODO: Reverse engineer this
        )
    }

    func getResume(seq: Int, sessionID: String) -> GatewayResume? {
        guard let token: String = Keychain.load(key: "authToken")
        else { return nil }
        
        return GatewayResume(
            token: token,
            session_id: sessionID,
            seq: seq
        )
    }
}

