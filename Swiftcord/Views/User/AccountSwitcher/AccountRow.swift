//
//  AccountRow.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 3/9/22.
//

import SwiftUI
import DiscordKitCore
import DiscordKit
import DiscordKitCommon
import os

struct AccountRow: View {
	let meta: AccountMeta
	let isCurrent: Bool

	@Binding var switcherPresented: Bool

	@EnvironmentObject var gateway: DiscordGateway
	@EnvironmentObject var restAPI: DiscordREST
	@EnvironmentObject var state: UIState
	@EnvironmentObject var switcher: AccountSwitcher

	static let log = Logger(category: "AccountRow")

	var body: some View {
		HStack(spacing: 8) {
			BetterImageView(url: meta.avatar)
				.clipShape(Circle())
				.frame(width: 40, height: 40)
			VStack(alignment: .leading) {
				Text(verbatim: meta.name).font(.title3)
				+ Text("#\(meta.discrim)").foregroundColor(.secondary)
				if isCurrent {
					Text("Active account")
						.font(.headline)
						.foregroundColor(.green)
				}
			}
			Spacer()

			if !isCurrent {
				Button {
					switcher.setActiveAccount(id: meta.id)
					guard let newToken = switcher.getActiveToken() else {
						AccountRow.log.error("No active token associated with account. This should never happen!")
						return
					}
					state.loadingState = .initial
					gateway.disconnect()
					restAPI.setToken(token: newToken)
					gateway.connect(token: newToken)
					switcherPresented = false
				} label: {
					Text("Switch")
				}
				.buttonStyle(FlatButtonStyle(prominent: false))
				.controlSize(.small)
			}
		}
		.padding(.vertical, 12)
		.padding(.horizontal, 16)
	}
}
