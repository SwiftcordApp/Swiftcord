//
//  ServerJoinView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 9/7/22.
//

import SwiftUI

struct ServerJoinView: View {
	@Binding var presented: Bool

	@State private var invite = ""

    var body: some View {
		VStack(spacing: 16) {
			VStack(spacing: 4) {
				Text("server.join.title").font(.title)
				Text("server.join.caption").frame(maxWidth: .infinity, alignment: .center)
			}

			VStack(alignment: .leading, spacing: 8) {
				Text("server.join.fieldHeader").textCase(.uppercase).font(.headline).opacity(0.75)
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

			HStack {
				Button(action: { presented = false }) {
					Text("action.close")
				}
				.buttonStyle(.plain)
				Spacer()
				Button(action: { presented = false }) {
					Text("server.join.action")
				}
				.controlSize(.large)
				.buttonStyle(.borderedProminent)
			}
		}
		.padding(16)
		.frame(width: 408)
    }
}
