//
//  MessageInfoBarView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 10/5/22.
//

import SwiftUI

struct InfoBarData {
    let message: LocalizedStringKey
    let buttonLabel: LocalizedStringKey
    let color: Color
    var buttonIcon: String?
    let clickHandler: () -> Void
}

struct MessageInfoBarView: View {
    @Binding var isShown: Bool
    @Binding var state: InfoBarData?

    var body: some View {
        HStack {
            Text(state?.message ?? "''")
            Spacer()
			if let label = state?.buttonLabel {
				Button { state!.clickHandler() } label: {
					if let icon = state?.buttonIcon {
						HStack(spacing: 4) {
							Text(label)
							Image(systemName: icon)
						}
					} else { Text(label) }
				}.buttonStyle(.plain)
			}
        }
		.foregroundColor(.white)
        .frame(height: 24)
        .padding(.horizontal) // Padding for content
        .padding(.bottom, 14)
		.background(state?.color ?? .clear)
        .cornerRadius(8) // Visually match corner radius to message field
        .padding(.horizontal, 16) // Padding outside the background
        .offset(y: isShown ? -48 : -24)
		.opacity(isShown ? 1 : 0)
        .animation(
            .interpolatingSpring(
				mass: 1.2,
				stiffness: 500,
				damping: 30,
				initialVelocity: isShown ? 0.03 : 0
			),
            value: isShown
        )
    }
}
