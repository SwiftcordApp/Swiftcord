//
//  Native_DiscordApp.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import DiscordKit
import SwiftUI

@main
struct SwiftcordApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	let persistenceController = PersistenceController.shared
	@StateObject var updaterViewModel = UpdaterViewModel()

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
		.commands {
			CommandGroup(after: .appInfo) {
				CheckForUpdatesView(updaterViewModel: updaterViewModel)
			}
			
			SidebarCommands()
			NavigationCommands()
		}

		Settings {
			SettingsView()
				.environmentObject(gateway)
				.environmentObject(state)
		}
	}
}
