//
//  UserSettingsAccountView.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import SwiftUI
import DiscordKit
import DiscordKitCore
import CachedAsyncImage

struct UserSettingsAccountView: View {
	let user: CurrentUser

	@State private var changePwSheetShown = false
	@State private var oldPw = ""
	@State private var newPw = ""
	@State private var confirmNewPw = ""
    
    @EnvironmentObject var gateway: DiscordGateway
    @EnvironmentObject var state: UIState
    @EnvironmentObject var switcher: AccountSwitcher

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
		VStack {
            CachedAsyncImage(url: user.avatarURL(size: 240)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView().progressViewStyle(.circular)
            }
            .clipShape(Circle())
            .frame(width: 100, height: 100)
            Text(user.username).font(.title2)
            Text(user.email)

            GroupBox {
                VStack(alignment: .leading, spacing: 4) {
                    Text("settings.user.phoneNum").textCase(.uppercase).font(.headline).opacity(0.75)
                    Text(user.phone ?? "You haven't added a phone number yet.")
                        .font(.system(size: 16))
                        .textSelection(.enabled)
                }.padding(10).frame(maxWidth: .infinity)
			}

            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password and Authenthication").font(.title2)
                    Divider()
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
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            GroupBox {
                VStack(alignment: .leading){
                    Text("settings.user.logOut").font(.title2)
                }
                Divider()
                VStack(alignment: .center){
                    Button("settings.user.logOut", role: .destructive) {
                        Task {
                            await switcher.logOut(id: user.id)
                            if switcher.accounts.isEmpty {
                                gateway.disconnect()
                                state.attemptLogin = true
                                state.loadingState = .initial
                            } else {
                                switchAccount() // Switch to the next available account
                            }
                        }
                    }
                }
                .buttonStyle(FlatButtonStyle())
                .controlSize(.small)
            }

			Group {
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
		}
	}
    private func switchAccount() {
        switcher.setActiveAccount(id: user.id)
        guard let newToken = switcher.getActiveToken() else {
            AccountRow.log.error("No active token associated with account. This should never happen!")
            return
        }
        state.loadingState = .initial
        gateway.disconnect()
        restAPI.setToken(token: newToken)
        gateway.connect(token: newToken)    }
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
