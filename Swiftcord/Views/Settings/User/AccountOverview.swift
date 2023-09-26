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
			VStack {
				HStack(spacing: 0) {
					CachedAsyncImage(url: user.avatarURL(size: 240)) { image in
						image.resizable().scaledToFill()
					} placeholder: {
						ProgressView().progressViewStyle(.circular)
					}
					.clipShape(Circle())
					.frame(width: 70, height: 70)
					.padding(5)
					.overlay {
						Circle()
							.strokeBorder(.white.opacity(0.5), lineWidth: 2)
					}
					.padding()
					VStack(alignment: .leading) {
						Text(user.username).font(.title)/*.padding(.top, 6)*/
						Text("#" + user.discriminator)
							.font(.system(.title3, weight: .bold))
					}
					Spacer()
					Button(action: {
						if let url = URL(string: "https://discord.com/channels/@me") {
								NSWorkspace.shared.open(url)
							}
					}, label: {
						HStack {
							Text("Edit Profile")
							Image(systemName: "link")
						}
						.frame(width: 131, height: 32)
						.background(Color.accentColor)
						.cornerRadius(5)
					})
					.buttonStyle(.plain)
				}
				.padding()
				//.background(Color.green.opacity(0.5))
				VStack {
					List {
						HStack {
							VStack(alignment: .leading) {
								Text("Name")
									.font(.system(.title3, weight: .bold))
								Text(user.username + "#" + user.discriminator)
									.font(.system(.title3, weight: .regular))
							}
							Spacer()
						}
						if let phone = user.phone {
							HStack {
								VStack(alignment: .leading) {
									Text("Phone")
										.font(.system(.title3, weight: .bold))
									Text(phone)
										.font(.system(.title3, weight: .regular))
								}
								Spacer()
							}
						} else {
							HStack {
								VStack(alignment: .leading) {
									Text("Phone")
										.font(.system(.title3, weight: .bold))
									Text("No Phone Number Added")
										.font(.system(.title3, weight: .regular))
								}
								Spacer()
							}
						}
						HStack {
							VStack(alignment: .leading) {
								Text("Email")
									.font(.system(.title3, weight: .bold))
								Text(user.email)
									.font(.system(.title3, weight: .regular))
							}
							Spacer()
						}
					}
					.cornerRadius(15)
					.padding()
				}
			}
			.foregroundColor(.primary)
			.frame(maxWidth: .infinity)
			.padding(.top, -10)
			.padding(.bottom, 10)
			.background(Color.black.opacity(0.4))
			.cornerRadius(15)
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
