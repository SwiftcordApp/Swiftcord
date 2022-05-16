//
//  GetSuperProperties.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 13/5/22.
//

import Foundation

public extension DiscordAPI {
	static func getSuperProperties() -> GatewayConnProperties {
		var systemInfo = utsname()
		uname(&systemInfo)

		// Ugly method to turn C char array into String
		func parseUname<T>(ptr: UnsafePointer<T>) -> String {
			ptr.withMemoryRebound(
				to: UInt8.self,
				capacity: MemoryLayout.size(ofValue: ptr)
			) { return String(cString: $0) }
		}

		let release = withUnsafePointer(to: systemInfo.release) {
			parseUname(ptr: $0)
		}
		// This should be called arch instead
		let machine = withUnsafePointer(to: systemInfo.machine) { parseUname(ptr: $0) }

		return GatewayConnProperties(
			os: "Mac OS X",
			browser: "Discord Client",
			release_channel: GatewayConfig.default.parity.releaseCh.rawValue,
			client_version: GatewayConfig.default.parity.version,
			os_version: release,
			os_arch: machine,
			system_locale: Locale.englishUS.rawValue,
			client_build_number: GatewayConfig.default.parity.buildNumber
		)
	}

	static var userAgent: String {
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) discord/\(GatewayConfig.default.parity.version) Chrome/91.0.4472.164 Electron/\(GatewayConfig.default.parity.electronVersion) Safari/537.36"
	}
}
