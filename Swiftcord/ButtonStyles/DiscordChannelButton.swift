//
//  DiscordChannelButton.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 16/6/22.
//

import SwiftUI

struct DiscordChannelButton: ButtonStyle {
	let isSelected: Bool
	@State var isHovered: Bool = false

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.buttonStyle(.borderless)
			.font(.system(size: 14, weight: isSelected ? .medium : .regular))
			.foregroundColor(isSelected ? Color(nsColor: .labelColor) : .gray)
			.accentColor(isSelected ? Color(nsColor: .labelColor) : .gray)
			.background(
				RoundedRectangle(cornerRadius: 5)
					.fill(isSelected ? .gray.opacity(0.3) : (isHovered ? .gray.opacity(0.2) : .clear))
			)
			.onHover(perform: { isHovered = $0 })
	}
}
