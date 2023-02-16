//
//  AvatarWithPresence.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/9/22.
//

import SwiftUI
import DiscordKitCore

struct AvatarWithPresence: View {
	let avatarURL: URL
	let presence: PresenceStatus
	let animate: Bool

	@Environment(\.controlSize) private var controlSize: ControlSize

	var body: some View {
		let size: CGFloat = controlSize == .small ? 32 : controlSize == .regular ? 80 : 128,
			punchSize = size * (controlSize == .small ? 0.5 : controlSize == .regular ? 0.35 : 0.333),
			presenceSize: CGFloat = punchSize - size*(controlSize == .small ? 0.09375 : 0.075)*2, // Spacing = size * 0.075
			rad: CGFloat = size/2,
			punchOffset = rad + rad * cos(1/4*CGFloat.pi)

		ZStack(alignment: .topLeading) {
			Group {
				if animate, avatarURL.isAnimatable {
					SwiftyGifView(url: avatarURL.modifyingPathExtension("gif"))
				} else {
					BetterImageView(url: avatarURL)
				}
			}
			.clipShape(Circle())
			.frame(width: size, height: size)

			// Presence indicator
			ZStack {
				// Hole punch in avatar
				Circle()
					.fill(.white)
					.frame(width: punchSize, height: punchSize)
					.blendMode(.destinationOut)

				ZStack(alignment: .topLeading) {
					// Main background
					Circle()
						.strokeBorder(.gray, lineWidth: presence == .offline || presence == .invisible ? presenceSize*0.25 : 0)
                        .background(Circle().fill(
                            presence == .online ? .green :
                            presence == .dnd ? .red :
                            presence == .idle ? .orange : .clear
                        ))
						.frame(width: presenceSize, height: presenceSize)
						.animation(.default, value: presence)
					// Idle cutout
					// r = 0.375, cx = 0.25, cy = 0.25
					Circle()
						.fill(.white)
                        .frame(
                            width: presence == .idle ? presenceSize*0.75 : 0,
                            height: presence == .idle ? presenceSize*0.75 : 0
                        )
						.offset(x: presenceSize * -0.125, y: presenceSize * -0.125) // 0.25 - 0.375
						.animation(.easeOut, value: presence == .idle)
						.blendMode(.destinationOut)
				}

				// DND capsule
				Capsule()
					.fill(.white)
					.frame(width: presence == .dnd ? presenceSize * 0.75 : 0, height: presenceSize * 0.25)
					.animation(.default, value: presence == .dnd)
					.blendMode(.destinationOut)
			}
			.contentShape(Circle())
			.help(presence.toLocalizedString())
			.offset(x: punchOffset-punchSize/2, y: punchOffset-punchSize/2)
		}
		.compositingGroup()
	}
}
