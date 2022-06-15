//
//  AppDelegate.swift
//  Swiftcord
//
//  Created by Vincent on 4/14/22.
//

import Foundation
import AppKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		setupURLCache()
		clearOldCache()

#if DEBUG
		AppCenter.logLevel = .debug
#endif

		if BuildSettings.appcenterAppSecret.isEmpty == false {
			// Start AppCenter if we have a valid app secret
			AppCenter.start(withAppSecret: BuildSettings.appcenterAppSecret, services: [
				Analytics.self,
				Crashes.self
			])
		}
	}

    /*func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        /// Close the app when there are no more open windows
        /// This is mostly to fix bugs occuring when windows are
        /// reopened after all windows are closed
        return true
    }*/
}

private extension AppDelegate {
	/// Overwrite shared URLCache with a higher capacity one
	func setupURLCache() {
		URLCache.shared = URLCache(
			memoryCapacity: 32 * 1024 * 1024,  // 32MB
			diskCapacity: 256 * 1024 * 1024, // 256MB
			diskPath: nil
		)
	}

	// Remove cached files older than the specified number of hours
	func clearOldCache() {
		let hoursThreshold = 24

		do {
			if let directories = try? FileManager.default.contentsOfDirectory(atPath: FileManager.default.temporaryDirectory.path) {
				for directory in directories {
					let directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(directory)
					let directoryAttributes = try FileManager.default.attributesOfItem(atPath: directoryURL.path)
					if let creationDate = directoryAttributes[FileAttributeKey.creationDate] as? Date {
						if let diff = Calendar.current.dateComponents([.hour], from: creationDate, to: Date()).hour, diff > hoursThreshold {
							try FileManager.default.removeItem(at: directoryURL)
						}
					}
				}
			}
		} catch {
			print(error)
		}
	}
}
