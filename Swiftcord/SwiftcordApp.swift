//
//  Native_DiscordApp.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import DiscordKit
import SwiftUI

@main
struct SwiftcordApp: App, Equatable {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	let persistenceController = PersistenceController.shared
	@StateObject var updaterViewModel = UpdaterViewModel()

	@StateObject private var gateway = DiscordGateway()
	@StateObject private var state = UIState()

	var body: some Scene {
		WindowGroup {
			ContentView()
				.preferredColorScheme(gateway.cache.userSettings?.theme == UITheme.light ? .light : .dark)
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
				.preferredColorScheme(gateway.cache.userSettings?.theme == .light ? .light : .dark)
				.environmentObject(gateway)
				.environmentObject(state)
		}
	}

	static func == (lhs: SwiftcordApp, rhs: SwiftcordApp) -> Bool {
		lhs.gateway == rhs.gateway && lhs.state == rhs.state
	}
}
