//
//  UserSettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI
import DiscordKit
import DiscordKitCommon
import DiscordKitCore

struct UserSettingsView: View {
    let user: CurrentUser

	@State private var selectedLink: SidebarLink? = .account
    @EnvironmentObject var gateway: DiscordGateway
	@EnvironmentObject var rest: DiscordREST

	private let keyPrefixesToRemove = [
		"lastCh.",
		"local.",
		"lastSelectedGuild",
		"showSendBtn",
		"stickerAlwaysAnim",
		"theme",
		"ttsRate"
	]

	private func logOut() {
		for key in UserDefaults.standard.dictionaryRepresentation().keys {
			for toRemove in keyPrefixesToRemove {
				if key.prefix(toRemove.count) == toRemove {
					UserDefaults.standard.removeObject(forKey: key)
					break
				}
			}
		}
		gateway.logout()
		Task { await rest.logOut() }
		Keychain.remove(key: SwiftcordApp.tokenKeychainKey)
	}

    var body: some View {
        NavigationView {
            List {
				NavigationLink("My Account", tag: .account, selection: $selectedLink) {
                    ScrollView { UserSettingsAccountView(user: user).padding(40) }
                }

				NavigationLink("User Profile", tag: .profile, selection: $selectedLink) {
					ScrollView { UserSettingsProfileView(user: user).padding(40) }
                }

				NavigationLink("Privacy & Safety", tag: .privacy, selection: $selectedLink) {
                    Text("")
                }

				NavigationLink("Authorized Apps", tag: .apps, selection: $selectedLink) {
                    Text("")
                }

				NavigationLink("Connections", tag: .connections, selection: $selectedLink) {
                    Text("")
                }

				NavigationLink("settings.user.logOut",
							   tag: SidebarLink.logOut, selection: $selectedLink) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("settings.user.logOut").font(.title)
                        Text("settings.user.logOut.confirmation")
						Text("Note: This will also delete your locally stored preferences")
							.font(.caption)
                        Button(role: .destructive) { logOut() } label: {
                            Label(
								"settings.user.logOut",
								systemImage: "rectangle.portrait.and.arrow.right"
							)
                        }
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .tint(.red)

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

private extension UserSettingsView {
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
