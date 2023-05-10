//
//  Native_DiscordApp.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import DiscordKit
import DiscordKitCore
import SwiftUI
import OSLog

// There's probably a better place to put global constants
let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String

// MARK: Global Objects
let restAPI = DiscordREST()

@main
struct SwiftcordApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	internal static let tokenKeychainKey = "authTokens"
	internal static let legacyTokenKeychainKey = "authToken"

	// let persistenceController = PersistenceController.shared
	#if !APP_STORE
	@StateObject var updaterViewModel = UpdaterViewModel()
	#endif
	@StateObject private var gateway = DiscordGateway()
	@StateObject private var state = UIState()
	@StateObject private var acctManager = AccountSwitcher()

	@AppStorage("theme") private var selectedTheme = "system"

	private static let log = Logger(category: "MainApp")

	var body: some Scene {
		WindowGroup {
			if state.attemptLogin {
				LoginView() // Doesn't matter if login view is big enough
					.environmentObject(gateway)
					.environmentObject(state)
					.environmentObject(acctManager)
					.navigationTitle("Login")
			} else {
				ContentView()
					.overlay(LoadingView())
					.environmentObject(gateway)
					.environmentObject(state)
					.environmentObject(acctManager)
				// .environment(\.locale, .init(identifier: "zh-Hans"))
				// .environment(\.managedObjectContext, persistenceController.container.viewContext)
					.preferredColorScheme(
						selectedTheme == "dark"
						? .dark
						: (selectedTheme == "light" ? .light : nil)
					)
					.onAppear {
						// Fix list assertion errors
						// The window has been marked as needing another Update Constraints in Window pass, but it has already had more Update Constraints in Window passes than there are views in the window.
						UserDefaults.standard.set(false, forKey: "NSWindowAssertWhenDisplayCycleLimitReached")

						guard gateway.socket == nil else { return }
						guard let token = acctManager.getActiveToken() else {
							state.attemptLogin = true
							return
						}
						gateway.connect(token: token)
						restAPI.setToken(token: token)
						_ = gateway.onAuthFailure.addHandler {
							Self.log.warning("Auth failed")
							guard acctManager.getActiveID() != nil else {
								Self.log.error("Current ID not found! Showing login instead.")
								state.attemptLogin = true
								state.loadingState = .initial
								return
							}
							acctManager.invalidate()
							// Switch to other account if possible
							if let token = acctManager.getActiveToken() {
								Self.log.debug("Attempting connection with other account")
								gateway.connect(token: token)
								restAPI.setToken(token: token)
							} else {
								state.attemptLogin = true
								state.loadingState = .initial
							}
						}
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
		.windowStyle(.hiddenTitleBar)
		.windowToolbarStyle(.unified)

		Settings {
			SettingsView()
				.environmentObject(gateway)
				.environmentObject(state)
				.environmentObject(acctManager)
				.environmentObject(updaterViewModel)
				.preferredColorScheme(
					selectedTheme == "dark"
					? .dark
					: (selectedTheme == "light" ? .light : .none)
				)
		}
	}
}

@available(macOS 13, *)
struct SettingsCommands: View {
	@Environment(\.openWindow) private var openWindow

	var body: some View {
		Divider()
		Button("Settings") {
			openWindow(id: "settings")
		}.keyboardShortcut(",", modifiers: .command)
	}
}
