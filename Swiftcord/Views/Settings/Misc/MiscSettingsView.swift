//
//  MiscSettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI
import DiscordKit

struct MiscSettingsView: View {
	@State private var selectedLink: SidebarLink? = .changelog

	@EnvironmentObject var gateway: DiscordGateway

    var body: some View {
        NavigationView {
			List {
				NavigationLink("Change Log", tag: .changelog, selection: $selectedLink) {
                    Text("Nothing")
                }

				NavigationLink("Hypesquad", tag: .hype, selection: $selectedLink) {
                    Text("Not hype")
                }

				NavigationLink("settings.others.about", tag: .about, selection: $selectedLink) {
                    AboutSwiftcordView()
                }

				NavigationLink("settings.others.credits", tag: .credits, selection: $selectedLink) {
					ScrollView {
						CreditsView().padding(40)
					}
				}

				/* if gateway.cache.userSettings?.developer_mode == true {
					NavigationLink("Debug", tag: .debug, selection: $selectedLink) {
						DebugSettingsView()
					}
				} */
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

private extension MiscSettingsView {
	enum SidebarLink: String {
		case changelog = "What's New"
		case hype = "HypeSquad"
		case about = "About"
		case credits = "Credits"
		case debug = "Debug"
	}
}
