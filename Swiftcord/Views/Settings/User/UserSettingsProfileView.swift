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

	@State private var about = ""

    var body: some View {
		Section {
			TextEditor(text: $about)
				.font(.body)
				.padding(.horizontal, -4)
				.overlay(alignment: .topLeading) {
					if about.isEmpty {
						// Fake placeholder, for some reason supplying a placeholder to TextField appears as a label, and TextEditor doesn't support placeholders
						Text("Write all about yourself!").foregroundColor(.secondary)
					}
				}
			Text("You can use markdown and links if you'd like.").font(.callout)
		} header: {
			Text("About Me")
		} footer: {
			VStack(alignment: .leading) {
				Text("Preview").font(.headline)
				MiniUserProfileView(
					user: User(from: user),
					member: nil
				) {
					Text("Customising my profile").font(.headline).textCase(.uppercase)

					HStack(spacing: 12) {
						Image(systemName: "pencil.and.outline")
							.font(.system(size: 42, weight: .heavy))
							.frame(width: 64, height: 64)
							.background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.blue))
						Text("User Profile").font(.headline)
					}
					.padding(.vertical, 4)

					Button {} label: {
						Text("Example Button").frame(maxWidth: .infinity)
					}
					.buttonStyle(FlatButtonStyle())
					.controlSize(.small)
				}
				.background(Color(NSColor.controlBackgroundColor))
				.cornerRadius(8)
				.shadow(color: .black.opacity(0.24), radius: 8, x: 0, y: 4)
				.onAppear {
					about = user.bio ?? ""
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
    }
}
