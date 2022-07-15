//
//  ServerJoinView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 9/7/22.
//

import SwiftUI
import DiscordKitCore

struct ServerJoinView: View {
	@Binding var presented: Bool

	@State private var invite = ""
	@State private var error: LocalizedStringKey?

	@EnvironmentObject var rest: DiscordREST

    var body: some View {
		DialogView(
			title: "server.join.title",
			description: "server.join.caption",
			analyticsType: "Join Guild",
			analyticsFrom: "Guild List"
		) {
			Button { presented = false } label: {
				Text("action.close")
			}
			.buttonStyle(.plain)
			Spacer()
			Button {
				Task {
					let id = invite.split(separator: "/").last!
					AnalyticsWrapper.event(type: .inviteOpened, properties: ["invite_code": id])
					let resolvedInvite = await rest.resolveInvite(inviteID: String(id), inputValue: invite)
					AnalyticsWrapper.event(type: .networkInviteResolve, properties: [
						"code": id,
						"input_value": invite,
						"location": "Join Guild"
					])

					guard let resolvedInvite = resolvedInvite else {
						error = "server.join.fieldHeader.notFound"
						AnalyticsWrapper.event(type: .resolveInvite, properties: [
							"input_value": invite,
							"invite_type": "Server Invite",
							"location": "Join Guild",
							"code": id,
							"resolved": false
						])
						return
					}
					AnalyticsWrapper.event(type: .resolveInvite, properties: [
						"input_value": invite,
						"invite_type": "Server Invite",
						"inviter_id": resolvedInvite.inviter?.id,
						"location": "Join Guild",
						"code": id,
						"resolved": true,
						"size_online": resolvedInvite.approximate_presence_count,
						"size_total": resolvedInvite.approximate_member_count
					])
					print(resolvedInvite)
					error = nil
				}
			} label: {
				Text("server.join.action")
			}
			.buttonStyle(FlatButtonStyle())
		} content: {
			Group {
				if let error = error {
					Text(error).foregroundColor(.red)
				} else {
					Text("server.join.fieldHeader")
				}
			}.textCase(.uppercase).font(.headline).opacity(0.75)

			TextField("https://discord.gg/hTKzmak", text: $invite)
				.textFieldStyle(.roundedBorder)
				.controlSize(.large)
				.padding(.bottom, 8)

			Text("server.join.egHeader").textCase(.uppercase).font(.headline).opacity(0.75)
			Text(verbatim: """
				 hTKzmak
				 https://discord.gg/hTKzmak
				 https://discord.gg/cool-people
				 """
			)
		}
    }
}
