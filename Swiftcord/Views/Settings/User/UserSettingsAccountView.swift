//
//  UserSettingsAccountView.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import SwiftUI
import DiscordKitCore

struct UserSettingsAccountView: View {
	let user: CurrentUser

	@State private var changePwSheetShown = false
	@State private var oldPw = ""
	@State private var newPw = ""
	@State private var confirmNewPw = ""

	var changePwDialog: some View {
		DialogView(
			title: "settings.user.chPwd.title",
			description: "settings.user.chPwd.caption"
		) {
			Button(action: { changePwSheetShown = false }) {
				Text("action.close")
			}
			.buttonStyle(.plain)
			Spacer()
			Button(action: { changePwSheetShown = false }) {
				Text("action.done")
			}
			.buttonStyle(FlatButtonStyle())
		} content: {
			PasswordField(placeholder: "Current password", prompt: "Enter your existing password", password: $oldPw)
			PasswordField(placeholder: "New password", prompt: "Enter a new password", password: $newPw)
				.padding(.top, 8)
			PasswordField(placeholder: "Confirm new password", prompt: "Confirm your new password", password: $confirmNewPw)
				.padding(.top, 8)
		}
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("My Account").font(.title)
			LargeUserProfile(user: user) {
				GroupBox {
					VStack(alignment: .leading, spacing: 4) {
						Text("Username").textCase(.uppercase).font(.headline).opacity(0.75)
						Group {
							Text(user.username) + Text("#" + user.discriminator).foregroundColor(Color(NSColor.textColor).opacity(0.75))
						}
						.font(.system(size: 16))
						.textSelection(.enabled)

						Divider().padding(.vertical, 10)

						Text("settings.user.email").textCase(.uppercase).font(.headline).opacity(0.75)
						Text(user.email)
							.font(.system(size: 16))
							.textSelection(.enabled)

						Divider().padding(.vertical, 10)

						Text("settings.user.phoneNum").textCase(.uppercase).font(.headline).opacity(0.75)
						Text(user.phone ?? "You haven't added a phone number yet.")
							.font(.system(size: 16))
							.textSelection(.enabled)
					}.padding(10).frame(maxWidth: .infinity)
				}
			}

			Group {
				Divider().padding(.vertical, 16)

				Text("Password and Authenthication").font(.title)
				Button(action: { changePwSheetShown = true }) {
					Text("Change Password")
				}
				.buttonStyle(FlatButtonStyle())
				.controlSize(.small)
				.sheet(isPresented: $changePwSheetShown, onDismiss: {
					oldPw = ""
					newPw = ""
				}) { changePwDialog }

				Text("TWO-FACTOR AUTHENTHICATION" + (user.mfa_enabled ? " ENABLED" : ""))
					.font(.headline)
					.foregroundColor(user.mfa_enabled ? .green : nil)
					.padding(.top, 12)
				Text("Two-Factor authentication (2FA for short) is a good way to add an extra layer of security to your Discord account to make sure that only you have the ability to log in.")
					.opacity(0.75)
					.padding(.top, -8)

				HStack(spacing: 16) {
					Button("View Backup Codes") {

					}
					.buttonStyle(FlatButtonStyle())
					.controlSize(.small)
					Button("Remove 2FA", role: .destructive) {

					}
					.buttonStyle(FlatButtonStyle(outlined: true))
					.controlSize(.small)
				}
			}

			Group {
				Divider().padding(.vertical, 16)

				Text("ACCOUNT REMOVAL")
					.font(.headline)
				Text("Disabling your account means you can recover it at any time after taking this action.")
					.opacity(0.75)
					.padding(.top, -8)
				HStack(spacing: 16) {
					Button("Disable Account", role: .destructive) {

					}
					.buttonStyle(FlatButtonStyle())
					.controlSize(.small)
					Button("Delete Account", role: .destructive) {

					}
					.buttonStyle(FlatButtonStyle(outlined: true))
					.controlSize(.small)
				}
			}

			Spacer()
		}
	}
}

private extension UserSettingsAccountView {
	struct PasswordField: View {
		let placeholder: String
		let prompt: String
		@Binding var password: String

		var body: some View {
			VStack(alignment: .leading, spacing: 8) {
				Text(placeholder)
					.font(.headline)
					.textCase(.uppercase)
					.foregroundColor(.secondary)

				SecureField(placeholder, text: $password, prompt: Text(prompt))
					.textFieldStyle(.roundedBorder)
					.controlSize(.large)
					.textFieldStyle(.roundedBorder)
			}
		}
	}
}
