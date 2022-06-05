//
//  LargeUserProfile.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI
import CachedAsyncImage
import DiscordKitCore

struct LargeUserProfile<Content: View>: View {
    let user: CurrentUser
    @ViewBuilder var slot: Content

    @State private var selectorIndex = 0

    var body: some View {
        let avatarURL = user.avatarURL(size: 240)

        VStack(alignment: .leading, spacing: 0) {
            if let accentColor = user.accent_color {
                Rectangle().fill(Color(hex: accentColor))
                    .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
					.clipShape(ProfileAccentMask(insetStart: 16, insetWidth: 136))
            } else {
                CachedAsyncImage(url: avatarURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: { ProgressView().progressViewStyle(.circular)}
                .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                .blur(radius: 12)
                .clipped()
				.clipShape(ProfileAccentMask(insetStart: 16, insetWidth: 136))
            }
            HStack(alignment: .bottom, spacing: 12) {
				CachedAsyncImage(url: avatarURL) { image in
					image.resizable().scaledToFill()
				} placeholder: {
					ProgressView().progressViewStyle(.circular)
				}
				.clipShape(Circle())
				.frame(width: 120, height: 120)
				.padding(8)

                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        Text(user.username) +
                        Text("#" + user.discriminator)
                            .foregroundColor(Color(NSColor.textColor).opacity(0.75))
                    }
                    .font(.title2)
                    HStack {
						let flags = User.Flags.allCases.filter { user.flags.contains($0) }
						ForEach(flags) { flag in
							if let badge = ProfileBadges.badgeMapping[flag] {
								Image(badge).frame(width: 22, height: 22)
							}
                        }
                        if user.premium {
                            Image("NitroSubscriber").frame(width: 22, height: 22)
                        }
                    }.frame(height: 24)
                }.padding(.bottom, 6)
            }
            .padding(.top, -68)
            .padding(.bottom, -8)
            .padding(.leading, 16)

            slot
                .frame(maxWidth: .infinity)
                .padding(16)
        }
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}
