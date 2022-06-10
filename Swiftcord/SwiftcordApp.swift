//
//  Native_DiscordApp.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import DiscordKit
import DiscordKitCore
import SwiftUI

// There's probably a better place to put global constants
let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String

@main
struct SwiftcordApp: App {
	static internal let tokenKeychainKey = "authToken"

	// @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	// let persistenceController = PersistenceController.shared
	@StateObject var updaterViewModel = UpdaterViewModel()
	@StateObject private var gateway = DiscordGateway()
	@StateObject private var restAPI = DiscordREST()
	@StateObject private var state = UIState()

	@AppStorage("theme") private var selectedTheme = "system"

	var body: some Scene {
		WindowGroup {
			ContentView()
				.overlay(LoadingView())
				.environmentObject(gateway)
				.environmentObject(state)
				.environmentObject(restAPI)
				// .environment(\.locale, .init(identifier: "zh-Hans"))
				// .environment(\.managedObjectContext, persistenceController.container.viewContext)
				.preferredColorScheme(selectedTheme == "dark"
									  ? .dark
									  : (selectedTheme == "light" ? .light : nil))
				.onAppear {
					guard let token = Keychain.load(key: SwiftcordApp.tokenKeychainKey) else {
						state.attemptLogin = true
						return
					}
					gateway.connect(token: token)
					restAPI.setToken(token: token)
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
				.environmentObject(gateway)
				.environmentObject(state)
				.preferredColorScheme(selectedTheme == "dark"
									  ? .dark
									  : (selectedTheme == "light" ? .light : nil))
				// .environment(\.locale, .init(identifier: "zh-Hans"))
		}
	}
}
