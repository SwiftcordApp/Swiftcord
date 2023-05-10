//
//  UserSecurity.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 9/5/23.
//

import SwiftUI
import DiscordKitCore

struct UserSecurity: View {
	let user: CurrentUser

	@State private var changePwSheetShown = false
	@State private var oldPw = ""
	@State private var newPw = ""
	@State private var confirmNewPw = ""

	var changePwDialog: some View {
		DialogView(title: "settings.user.chPwd.title", description: "settings.user.chPwd.caption") {
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
		Section("Password") {
			Button(action: { changePwSheetShown = true }) {
				Text("Change Password")
			}
			.buttonStyle(FlatButtonStyle())
			.controlSize(.small)
			.sheet(isPresented: $changePwSheetShown, onDismiss: {
				oldPw = ""
				newPw = ""
			}) { changePwDialog }
		}

		Section {
			Text("Two-Factor authentication (2FA for short) is a good way to add an extra layer of security to your Discord account to make sure that only you have the ability to log in.")

			HStack {
				Button("View Backup Codes") {

				}
				.buttonStyle(FlatButtonStyle())
				.controlSize(.small)
				Button("Remove 2FA", role: .destructive) {

				}
				.buttonStyle(FlatButtonStyle(outlined: true))
				.controlSize(.small)
			}
		} header: {
			Text("Two-Factor Authentication" + (user.mfa_enabled ? " (Enabled)" : ""))
				.foregroundColor(user.mfa_enabled ? .green : nil)
		}
    }
}
