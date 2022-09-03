//
//  CurrentUserFooter+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 3/9/22.
//

import SwiftUI

extension CurrentUserFooter {
	@ViewBuilder func accountSwitcher() -> some View {
		DialogView(title: "Manage Accounts", description: "Switch accounts, sign in, sign out, go wild.") {
			Button { switcherPresented = false } label: {
				Text("action.close")
			}
			.buttonStyle(.plain)
			Spacer()
			Button {
				switcherPresented = false
				loginPresented = true
			} label: {
				Text("Add an account")
			}
			.buttonStyle(FlatButtonStyle(prominent: false))
			.controlSize(.small)
		} content: {
			GroupBox {
				ScrollView {
					LazyVStack(spacing: 0) {
						ForEach(accounts, id: \.id) { account in
							AccountRow(
								avatarURL: user.avatarURL(size: 80),
								username: user.username,
								discriminator: user.discriminator,
								isCurrent: account.id == user.id
							)
							if account != accounts.last {
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
