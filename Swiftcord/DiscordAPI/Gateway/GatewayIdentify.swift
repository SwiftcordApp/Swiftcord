//
//  Identify.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

extension DiscordGateway {
    func getIdentify() -> GatewayIdentify? {
        // Keychain.save(key: "token", data: "token goes here")
        // Keychain.remove(key: "token") // For testing
        guard let token: String = Keychain.load(key: "token")
        else { return nil }
        
        // Ugly method to turn C char array into String
        func parseUname<T>(ptr: UnsafePointer<T>) -> String {
            ptr.withMemoryRebound(
                to: UInt8.self,
                capacity: MemoryLayout.size(ofValue: ptr)
            ) { return String(cString: $0) }
        }
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let release = withUnsafePointer(to: systemInfo.release) {
            parseUname(ptr: $0)
        }
        // This should be called arch instead
        let machine = withUnsafePointer(to: systemInfo.machine) { parseUname(ptr: $0) }
        
        let properties = GatewayConnProperties(
            os: "Mac OS X",
            browser: "Discord Client",
            release_channel: apiConfig.parity.releaseCh.rawValue,
            client_version: apiConfig.parity.version,
            os_version: release,
            os_arch: machine,
            system_locale: Locale.englishUS.rawValue,
            client_build_number: apiConfig.parity.buildNumber
        )
            
        return GatewayIdentify(
            token: token,
            properties: properties,
            compress: false,
            large_threshold: nil,
            shard: nil,
            presence: nil,
            capabilities: 253
        )
    }

    func getResume(seq: Int, sessionID: String) -> GatewayResume? {
        guard let token: String = Keychain.load(key: "token")
        else { return nil }
        
        return GatewayResume(
            token: token,
            session_id: sessionID,
            seq: seq
        )
    }
}

