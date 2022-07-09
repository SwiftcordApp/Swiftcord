//
//  ServerJoinView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 9/7/22.
//

import SwiftUI

struct ServerJoinView: View {
	@Binding var presented: Bool

    var body: some View {
		VStack(spacing: 32) {
			VStack(spacing: 4) {
				Text("server.join.title").font(.title)
				Text("server.join.caption").frame(maxWidth: .infinity, alignment: .center)
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
