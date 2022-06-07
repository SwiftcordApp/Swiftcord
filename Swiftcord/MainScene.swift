//
//  MainScene.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 7/6/22.
//

import SwiftUI

struct MainScene: Scene {
	let token: String

	@StateObject var updaterViewModel = UpdaterViewModel()
	@EnvironmentObject var state: UIState

	@AppStorage("theme") private var selectedTheme = "system"

    var body: some Scene {
		WindowGroup {
			ContentView()
				.overlay(LoadingView())
				//.environmentObject(gateway)
				.environmentObject(state)
				// .environment(\.locale, .init(identifier: "zh-Hans"))
				// .environment(\.managedObjectContext, persistenceController.container.viewContext)
				.preferredColorScheme(selectedTheme == "dark"
									  ? .dark
									  : (selectedTheme == "light" ? .light : nil))
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
				//.environmentObject(gateway)
				.environmentObject(state)
				.preferredColorScheme(selectedTheme == "dark"
								   ? .dark
								   : (selectedTheme == "light" ? .light : nil))
			// .environment(\.locale, .init(identifier: "zh-Hans"))
		}
    }
}
