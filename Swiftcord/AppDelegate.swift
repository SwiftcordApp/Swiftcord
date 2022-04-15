//
//  AppDelegate.swift
//  Swiftcord
//
//  Created by Vincent on 4/14/22.
//

import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        /// Close the app when there are no more open windows
        /// This is mostly to fix bugs occuring when windows are
        /// reopened after all windows are closed
        return true
    }
}
