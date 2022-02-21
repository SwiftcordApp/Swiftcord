//
//  Identify.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

func getIdentify() -> GatewayIdentify? {
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
        release_channel: "canary",
        client_version: "0.0.283",
        os_version: release,
        os_arch: machine,
        system_locale: Locale.englishUS.rawValue
    )
    
    // Keychain.save(key: "token", data: "OTQ0NTU0MTQzNTY0MDcwOTgy.YhDT8Q.uRXsgtqx96mqgyYlvXru6GoyOV8")
        
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
