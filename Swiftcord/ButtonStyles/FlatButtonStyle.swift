//
//  FlatButtonStyle.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 16/6/22.
//

import SwiftUI

struct FlatButtonStyle: ButtonStyle {
	// Use vars so not all params have to be supplied all the time
	var prominent = true
	var outlined = false
	var customBase: Color?

	@State private var hovered = false

	@Environment(\.controlSize) private var controlSize: ControlSize
	@Environment(\.isEnabled) private var enabled: Bool

	func makeBody(configuration: Configuration) -> some View {
		let base: Color = customBase ?? (configuration.role == .destructive ? .red : (prominent ? .accentColor : .init(nsColor: .controlColor)))
		let pressedStyles = configuration.isPressed && !outlined
		let hoverStyles = (hovered && !outlined) || (configuration.isPressed && outlined)
		let accent = enabled
			? (base.modifyingHSB(
				1,
				pressedStyles ? 0.98 : (hoverStyles ? 0.96 : 1),
				pressedStyles ? 0.67 : (hoverStyles ? 0.76 : 1)
			))
			: .gray.opacity(0.25)
		let background = outlined && !hovered ? .clear : accent

		configuration.label
			.padding(.horizontal, controlSize == .large ? 20 : 16)
			.frame(height: controlSize == .large ? 48 : (controlSize == .small ? 32 : 38))
			.frame(minWidth: controlSize == .small ? 60 : 96)
			.font(.system(size: controlSize == .large ? 16 : 14, weight: .medium))
			.background(background)
			.cornerRadius(4)
			.overlay {
				RoundedRectangle(cornerRadius: 4)
					.strokeBorder(outlined ? accent : .clear)
			}
			.foregroundColor(background.contrastColor().opacity(enabled ? 1 : 0.5))
			.animation(.easeOut(duration: 0.17), value: configuration.isPressed ? 1 : (hovered ? 2 : 3))
			.onHover { over in hovered = over }
	}
}
