//
//  FlatButtonStyle.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 16/6/22.
//

import SwiftUI

struct FlatButtonStyle: ButtonStyle {
	@Environment(\.controlSize) private var controlSize: ControlSize
	@Environment(\.isEnabled) private var enabled: Bool

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.frame(height: controlSize == .large ? 48 : 32)
			.font(controlSize == .large ? .title3 : .body)
			.background(
				enabled
					? Color.accentColor.opacity(configuration.isPressed ? 0.7 : 1)
					: .gray.opacity(0.25)
			)
			.cornerRadius(4)
			.animation(.easeOut(duration: 0.17), value: configuration.isPressed)
	}
}
