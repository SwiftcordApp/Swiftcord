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
import Sentry

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        populateUserDefaults()
        setupURLCache()
        clearOldCache()

        #if DEBUG
        AppCenter.logLevel = .debug
        #endif

        if BuildSettings.appcenterAppSecret.isEmpty == false {
            // Start AppCenter if we have a valid app secret
            AppCenter.start(withAppSecret: BuildSettings.appcenterAppSecret, services: [
                Analytics.self
            ])
            Analytics.enabled = UserDefaults.standard.bool(forKey: "local.analytics")
        }

        #if !DEBUG
        SentrySDK.start { options in
            options.dsn = "https://e7d39f98a63347c18b9f71d3aee6a4d3@o1377212.ingest.sentry.io/6687560"
            options.tracesSampleRate = 0.5
            options.enableAppHangTracking = true
        }
        #endif

        // Disable tabbing (fixes #114)
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    /*func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
     /// Close the app when there are no more open windows
     /// This is mostly to fix bugs occuring when windows are
     /// reopened after all windows are closed
     return true
     }*/
}

private extension AppDelegate {
    func populateUserDefaults() {
        UserDefaults.standard.register(defaults: [
            "local.analytics": true,
            "local.seenOnboarding": false
        ])
    }
}

private extension AppDelegate {
    /// Overwrite shared URLCache with a higher capacity one
    func setupURLCache() {
        /*let cachePath = (try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true))?.appendingPathComponent("sharedCache", isDirectory: false)
        if let cachePath {
            do {
                try FileManager.default.createDirectory(at: cachePath, withIntermediateDirectories: true)
            } catch {
                print("Create new cache dir fail! \(error)")
                return
            }
        }
        print("Cache path: \(cachePath)")*/
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
