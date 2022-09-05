//
//  AvatarWithPresence.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/9/22.
//

import SwiftUI

struct AvatarWithPresence: View {
	let avatarURL: URL
	let mini: Bool

	var body: some View {
		let size: CGFloat = mini ? 32 : 80,
			rad: CGFloat = size/2,
			presenceSpacing: CGFloat = mini ? 3 : 6,
			presenceSize: CGFloat = mini ? 10 : 16,
			punchSize = presenceSize + presenceSpacing*2,
			punchOffset = rad + rad * cos(1/4*CGFloat.pi)

		ZStack(alignment: .topLeading) {
			Group {
				if avatarURL.isAnimatable {
					SwiftyGifView(url: avatarURL.modifyingPathExtension("gif"))
				} else {
					BetterImageView(url: avatarURL)
				}
			}
			.frame(width: size, height: size)
			.mask(AvatarHolePunch(size: size, punchOffset: punchOffset-punchSize/2, punchSize: punchSize))
			Circle()
				.fill(.gray)
				.frame(width: presenceSize, height: presenceSize)
				.offset(x: punchOffset-presenceSize/2, y: punchOffset-presenceSize/2)
		}
		.padding(6)
	}
}
