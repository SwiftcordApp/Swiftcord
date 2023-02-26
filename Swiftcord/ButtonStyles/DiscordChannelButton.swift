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

	@Environment(\.controlSize) var size: ControlSize

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.buttonStyle(.borderless)
			.frame(height: size == .large ? 42 : 32)
			.padding(.horizontal, 2)
			.font(.system(size: 15))
			.foregroundColor(isSelected ? Color(nsColor: .labelColor) : .gray)
			.accentColor(isSelected ? Color(nsColor: .labelColor) : .gray)
			.background {
				RoundedRectangle(cornerRadius: 5)
					.fill(isSelected ? .gray.opacity(0.3) : (isHovered ? .gray.opacity(0.2) : .clear))
			}
			.onHover { isHovered = $0 }
	}
}
