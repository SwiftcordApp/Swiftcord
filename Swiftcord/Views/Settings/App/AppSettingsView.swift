//
//  AppSettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI

struct AppSettingsView: View {
	@State private var selectedLink: SidebarLink? = .appearance

    var body: some View {
        NavigationView {
            List {
                NavigationLink("settings.app.appearance", tag: .appearance, selection: $selectedLink) {
					ScrollView { AppSettingsAppearanceView().padding(40) }
                }

                NavigationLink("settings.app.accessibility", tag: .accessibility, selection: $selectedLink) {
					ScrollView { AppSettingsAccessibilityView().padding(40) }
                }

                NavigationLink("settings.app.voiceVideo", tag: .voiceVideo, selection: $selectedLink) {
                    Text("")
                }

                NavigationLink("settings.app.textImages", tag: .textImages, selection: $selectedLink) {
                    Text("")
                }

                NavigationLink("settings.app.notifs", tag: .notifs, selection: $selectedLink) {
                    Text("")
                }

                NavigationLink("settings.app.keybinds", tag: .keybinds, selection: $selectedLink) {
                    Text("")
                }

                NavigationLink("settings.app.lang", tag: .lang, selection: $selectedLink) {
                    Text("")
                }

                NavigationLink("settings.app.streamer", tag: .streamer, selection: $selectedLink) {
                    Text("")
                }

                NavigationLink("settings.app.advanced", tag: .advanced, selection: $selectedLink) {
					ScrollView { AppSettingsAdvancedView().padding(40) }
                }
            }
			.listStyle(SidebarListStyle())
			.onAppear {
				AnalyticsWrapper.event(type: .settingsPaneViewed, properties: [
					"origin_pane": selectedLink?.rawValue ?? ""
				])
			}
			.onChange(of: selectedLink) { [selectedLink] newSelection in
				AnalyticsWrapper.event(type: .settingsPaneViewed, properties: [
					"destination_pane": newSelection?.rawValue ?? "",
					"origin_pane": selectedLink?.rawValue ?? ""
				])
			}
        }
    }
}

private extension AppSettingsView {
	// Raw values are for analytics events
	enum SidebarLink: String {
		case appearance = "Appearance"
		case accessibility = "Accessibility"
		case voiceVideo = "Voice & Video"
		case textImages = "Text & Images"
		case notifs = "Notifications"
		case keybinds = "Keybinds"
		case lang = "Language"
		case streamer = "Streamer Mode"
		case advanced = "Advanced"
	}
}
