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
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	static internal let tokenKeychainKey = "authToken"

	// let persistenceController = PersistenceController.shared
	#if !APP_STORE
	@StateObject var updaterViewModel = UpdaterViewModel()
	#endif
	@StateObject private var gateway = DiscordGateway()
	@StateObject private var restAPI = DiscordREST()
	@StateObject private var state = UIState()

	@AppStorage("theme") private var selectedTheme = "system"

	var body: some Scene {
		WindowGroup {
			if state.attemptLogin {
				LoginView()
					.environmentObject(gateway)
					.environmentObject(state)
					.environmentObject(restAPI)
			} else {
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
						guard gateway.socket == nil else { return }
						guard let token = Keychain.load(key: SwiftcordApp.tokenKeychainKey) else {
							state.attemptLogin = true
							return
						}
						gateway.connect(token: token)
						restAPI.setToken(token: token)
					}
			}
		}
		.commands {
			#if !APP_STORE
			CommandGroup(after: .appInfo) {
				CheckForUpdatesView(updaterViewModel: updaterViewModel)
			}
			#endif

			SidebarCommands()
			NavigationCommands(state: state, gateway: gateway)
		}

		Settings {
			SettingsView()
				.environmentObject(gateway)
				.environmentObject(restAPI)
				.environmentObject(state)
				.preferredColorScheme(selectedTheme == "dark"
									  ? .dark
									  : (selectedTheme == "light" ? .light : .none))
				// .environment(\.locale, .init(identifier: "zh-Hans"))
		}
	}
}
