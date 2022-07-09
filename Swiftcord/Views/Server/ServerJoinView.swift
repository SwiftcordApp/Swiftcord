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
			Text("Join a Server").font(.title)
			HStack {
				Button(action: { presented = false }) {
					Text("Close")
				}
				.buttonStyle(.plain)
				Spacer()
				Button(action: { presented = false }) {
					Text("Join Server")
				}
				.controlSize(.large)
				.buttonStyle(.borderedProminent)
			}
		}
    }
}
