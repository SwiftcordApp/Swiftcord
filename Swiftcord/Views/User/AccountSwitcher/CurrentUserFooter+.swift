//
//  CurrentUserFooter+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 3/9/22.
//

import SwiftUI

extension CurrentUserFooter {
	@ViewBuilder private func switcherActions() -> some View {
		Button { switcherPresented = false } label: {
			Text("action.close")
		}
		.buttonStyle(.plain)
		Spacer()

		Button {
			switcherHelpPresented = true
		} label: {
			Image(systemName: "questionmark.circle").font(.system(size: 24))
		}
		.buttonStyle(.plain)
		.contentShape(Circle())
		.padding(.trailing, 4)
		.popover(isPresented: $switcherHelpPresented, arrowEdge: .bottom) {
			VStack(alignment: .leading) {
				Text("About Account Switcher").font(.title2)
				Text("Add, switch to or log out of accounts")
					.lineLimit(nil)
				Divider()

				Group {
					Text("Adding Accounts").font(.headline)
					Text("You can as many accounts as you'd like")
					Text("Account tokens are securely stored in your keychain")
						.padding(.bottom, 4)
					Text("Switching Accounts").font(.headline)
					Text("Simply use the 'Switch' buttons to switch accounts")
						.padding(.bottom, 4)
					Text("Logging Out of Accounts").font(.headline)
					Text("Right click on any account to sign out of it")
				}
			}
			.padding()
			.frame(maxWidth: 400)
		}

		Button {
			switcherPresented = false
			loginPresented = true
		} label: {
			Text("Add an account")
		}
		.buttonStyle(FlatButtonStyle())
		.controlSize(.small)
	}

	@ViewBuilder func accountSwitcher() -> some View {
		DialogView(title: "Manage Accounts", description: "Switch accounts, sign in, sign out, go wild.") {
			switcherActions()
		} content: {
			GroupBox {
				ScrollView {
					LazyVStack(spacing: 0) {
						ForEach(switcher.accounts, id: \.id) { account in
							AccountRow(
								meta: account,
								isCurrent: account.id == user.id,
								switcherPresented: $switcherPresented
							)
							if account != switcher.accounts.last {
								Divider().padding(.horizontal, 16)
							}
						}
					}
				}
				.frame(maxHeight: 240)
				.padding(-4)
			}
		}
	}
}
