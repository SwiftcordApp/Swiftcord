//
//  UserSettingsProfileView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 30/5/22.
//

import SwiftUI
import DiscordKitCore

struct UserSettingsProfileView: View {
	let user: CurrentUser

	@State private var about = " "
	@State private var profile: UserProfile?

    var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			HStack(alignment: .top) {
				VStack(alignment: .leading) {
					Text("About Me").textCase(.uppercase).font(.headline)
					Text("You can use markdown and links if you'd like.").opacity(0.75)
					GroupBox {
						ScrollView {
							TextEditor(text: $about)
								.onAppear {
									about = user.bio ?? ""
								}
						}
					}
				}.frame(maxWidth: .infinity, alignment: .leading)

				VStack(alignment: .leading) {
					Text("Preview").textCase(.uppercase).font(.headline)
					MiniUserProfileView(
						user: User(from: user),
						profile: $profile
					) {
						Text("Customising my profile").font(.headline).textCase(.uppercase)
					}
					.background(Color(NSColor.controlBackgroundColor))
					.cornerRadius(8)
					.shadow(color: .black.opacity(0.24), radius: 16, x: 0, y: 8)
					.onAppear {
						profile = UserProfile(
							connected_accounts: [],
							user: User(from: user)
						)
					}
				}
			}
		}
    }
}
