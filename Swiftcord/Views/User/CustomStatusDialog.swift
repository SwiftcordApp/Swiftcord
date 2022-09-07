//
//  CustomStatusDialog.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 7/9/22.
//

import SwiftUI

struct CustomStatusDialog: View {
	let username: String
	@Binding var presented: Bool

	@State private var status = ""

    var body: some View {
		DialogView(title: "Set a custom status", description: nil) {
			Button("Cancel") {
				presented = false
			}.buttonStyle(.plain)
			Spacer()
			Button("Save") {
				presented = false
			}
			.buttonStyle(FlatButtonStyle())
		} content: {
			Text("What's cookin', \(username)?").textCase(.uppercase).font(.headline)
			TextField("Support has arrived!", text: $status)
				.textFieldStyle(.roundedBorder)
				.controlSize(.large)
		}
    }
}
