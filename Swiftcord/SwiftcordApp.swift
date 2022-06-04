//
//  Native_DiscordApp.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import DiscordKit
import SwiftUI

private enum CachedTheme: Int {
	case none = 0
	case dark = 1
	case light = 2
	case system = 3
}

@main
struct SwiftcordApp: App, Equatable {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	let persistenceController = PersistenceController.shared
	@StateObject var updaterViewModel = UpdaterViewModel()

	@StateObject private var gateway = DiscordGateway()
	@StateObject private var state = UIState()

	@AppStorage("cachedTheme") private var theme = CachedTheme.none

	var body: some Scene {
		WindowGroup {
			ContentView()
				.preferredColorScheme(theme == .dark ? .dark : (theme == .light ? .light : nil))
				.overlay(LoadingView())
				.environmentObject(gateway)
				.environmentObject(state)
				// .environment(\.locale, .init(identifier: "zh-Hans"))
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
				.onChange(of: gateway.cache.userSettings?.theme) { newTheme in
					guard let newTheme = newTheme else { return }
					if theme != .system { theme = newTheme == .dark ? .dark : .light }
				}
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
				.preferredColorScheme(theme == .dark ? .dark : (theme == .light ? .light : nil))
				.environmentObject(gateway)
				.environmentObject(state)
				// .environment(\.locale, .init(identifier: "zh-Hans"))
		}
	}

	static func == (lhs: SwiftcordApp, rhs: SwiftcordApp) -> Bool {
		lhs.gateway == rhs.gateway && lhs.state == rhs.state
	}
}
