//
//  UserSettings.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI
import DiscordKit
import DiscordKitCore

struct UserSettings: View {
    let user: CurrentUser

	@State private var selectedLink: SidebarLink? = .account
    @EnvironmentObject var gateway: DiscordGateway
	@EnvironmentObject var acctManager: AccountSwitcher

    var body: some View {
        NavigationView {
            List {
				NavigationLink("My Account", tag: .account, selection: $selectedLink) {
                    ScrollView { UserSettingsAccount(user: user).padding(40) }
                }

				NavigationLink("User Profile", tag: .profile, selection: $selectedLink) {
					ScrollView { UserSettingsProfileView(user: user).padding(40) }
                }

				NavigationLink("Privacy & Safety", tag: .privacy, selection: $selectedLink) {
					ScrollView { UserSettingsPrivacySafetyView().padding(40) }
                }

				NavigationLink("Authorized Apps", tag: .apps, selection: $selectedLink) {
                    Text("")
                }

				NavigationLink("Connections", tag: .connections, selection: $selectedLink) {
                    Text("")
                }

                NavigationLink("settings.user.logOut", tag: SidebarLink.logOut, selection: $selectedLink) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("settings.user.logOut").font(.title)
                        Text("Use the account switcher (found by clicking on your profile at the bottom of the channel list) to log out, switch or add accounts!")

                        Spacer()
                    }
                    .padding(40)
                    .frame(maxWidth: .infinity, alignment: .leading)
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

private extension UserSettings {
	// Raw values are for analytics events
	enum SidebarLink: String {
		case account = "My Account"
		case profile = "User Profile"
		case privacy = "Privacy & Safety"
		case apps = "Authorized Apps"
		case connections = "Connections"
		case logOut = "Log Out"
	}
}
