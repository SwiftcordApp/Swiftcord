//
//  Native_DiscordApp.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import SwiftUI

// Get rid of over the top focus indicator
extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

@main
struct SwiftcordApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    
    @StateObject private var gateway = DiscordGateway()
    @StateObject private var state = UIState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .overlay(LoadingView())
                .environmentObject(gateway)
                .environmentObject(state)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    // Overwrite shared URLCache with a higher capacity one
                    URLCache.shared = URLCache(
                        memoryCapacity: 32*1024*1024,  // 32MB
                          diskCapacity: 256*1024*1024, // 256MB
                              diskPath: nil
                    )
                }
        }
        
        Settings {
            SettingsView()
                .environmentObject(gateway)
                .environmentObject(state)
        }
    }
}
