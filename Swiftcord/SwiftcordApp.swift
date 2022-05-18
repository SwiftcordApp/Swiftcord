//
//  Native_DiscordApp.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import SwiftUI
import DiscordKit

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
        }
        
        Settings {
            SettingsView()
                .environmentObject(gateway)
                .environmentObject(state)
        }
    }
}
