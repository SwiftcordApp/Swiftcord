//
//  AccountOverview.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import SwiftUI
import DiscordKitCore
import CachedAsyncImage

@available(macOS 13.0, *)
struct AccountOverview: View {
	let user: CurrentUser

	var body: some View {
		Section {
			SettingsActionRow(label: "Name, Phone, Email", iconSystemName: "person.crop.circle") {
				UserInfo()
			}
			SettingsActionRow(label: "Password & Security", iconSystemName: "lock.fill") {
				UserSecurity(user: user)
			}
			SettingsActionRow(label: "Payment & Shipping", iconSystemName: "creditcard.fill") {
				UserInfo()
			}
		} header: {
			VStack(spacing: 0) {
				CachedAsyncImage(url: user.avatarURL(size: 240)) { image in
					image.resizable().scaledToFill()
				} placeholder: {
					ProgressView().progressViewStyle(.circular)
				}
				.clipShape(Circle())
				.frame(width: 100, height: 100)
				Text(user.username).font(.title2).padding(.top, 6)
				Text(user.email).font(.system(.title3, weight: .regular))
				if let phone = user.phone {
					Text(phone)
						.textSelection(.enabled)
				}
			}
			.foregroundColor(.primary)
			.frame(maxWidth: .infinity)
			.padding(.top, -10)
			.padding(.bottom, 10)
		}

		Section {
			HStack {
				Button("Disable Account", role: .destructive) {

				}
				.buttonStyle(FlatButtonStyle())
				.controlSize(.small)
				Button("Delete Account", role: .destructive) {

				}
				.buttonStyle(FlatButtonStyle(outlined: true))
				.controlSize(.small)
			}
			Text("Disabling your account means you can recover it at any time after taking this action.")
				.foregroundColor(.secondary)
				.font(.callout)
		} header: {
			Text("Account Removal")
		}
	}
}
