//
//  FlatMenuStyle.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 7/9/22.
//

import SwiftUI

// Currently disfunctional
struct FlatMenuStyle: MenuStyle {
	@State private var hovered = false

	@Environment(\.controlSize) private var controlSize: ControlSize
	@Environment(\.isEnabled) private var enabled: Bool

	func makeBody(configuration: Configuration) -> some View {
		let base: Color = .accentColor
		let accent = enabled ? base : .gray.opacity(0.25)
		let background = !hovered ? .clear : accent

		Menu(configuration)
			.controlSize(.regular)
			.padding(.horizontal, controlSize == .large ? 20 : 16)
			.frame(height: controlSize == .large ? 48 : (controlSize == .small ? 32 : 38))
			.frame(minWidth: controlSize == .small ? 60 : 96)
			.font(.system(size: controlSize == .large ? 16 : 14, weight: .medium))
			.background(background)
			.cornerRadius(4)
			.foregroundColor(background.contrastColor().opacity(enabled ? 1 : 0.5))
			.animation(.easeOut(duration: 0.17), value: hovered)
			.onHover { over in hovered = over }
	}
}
