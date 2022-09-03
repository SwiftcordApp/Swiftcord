//
//  AccountRow.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 3/9/22.
//

import SwiftUI

struct AccountRow: View {
	let avatarURL: URL
	let username: String
	let discriminator: String
	let isCurrent: Bool

	var body: some View {
		HStack(spacing: 8) {
			BetterImageView(url: avatarURL)
				.clipShape(Circle())
				.frame(width: 40, height: 40)
			VStack(alignment: .leading) {
				Text(verbatim: username).font(.title3)
				+ Text("#\(discriminator)").foregroundColor(.secondary)
				if isCurrent {
					Text("Active account")
						.font(.headline)
						.foregroundColor(.green)
				}
			}
			Spacer()
		}
		.padding(.vertical, 12)
		.padding(.horizontal, 16)
	}
}
