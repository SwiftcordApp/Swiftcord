//
//  MiniUserProfileView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/5/22.
//

import SwiftUI
import DiscordKit
import DiscordKitCore
import CachedAsyncImage

struct MiniUserProfileView<RichContentSlot: View>: View {
	let user: User
	let pasteboard = NSPasteboard.general
	@Binding var profile: UserProfile?
	var guildRoles: [Role]?
	var isWebhook: Bool = false
	var loadError: Bool = false
	@ViewBuilder var contentSlot: RichContentSlot

	@State private var note = ""

	@EnvironmentObject var gateway: DiscordGateway
	@Environment(\.colorScheme) var colorScheme

    var body: some View {
		let avatarURL = user.avatarURL()
		let presence = gateway.presences[user.id]

		VStack(alignment: .leading, spacing: 0) {
			if let banner = profile?.user.banner ?? user.banner {
				let url = banner.bannerURL(of: user.id, size: 600)
				Group {
					if url.isAnimatable {
						SwiftyGifView(url: url.modifyingPathExtension("gif"))
					} else {
						CachedAsyncImage(url: url) { image in
							image.resizable().scaledToFill()
						} placeholder: { Rectangle().fill(Color(hex: profile?.user.accent_color ?? 0)) }
					}
				}
				.frame(width: 300, height: 120)
				.clipShape(ProfileAccentMask(insetStart: 14, insetWidth: 92))
			} else if let accentColor = profile?.user.accent_color {
				Rectangle().fill(Color(hex: accentColor))
					.frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
					.clipShape(ProfileAccentMask(insetStart: 14, insetWidth: 92))
			} else {
				CachedAsyncImage(url: avatarURL) { image in
					image.resizable().scaledToFill()
				} placeholder: { EmptyView() }
					.frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
					.blur(radius: 4)
					.clipShape(ProfileAccentMask(insetStart: 14, insetWidth: 92))
			}
			HStack(alignment: .bottom, spacing: 4) {
				AvatarWithPresence(
					avatarURL: avatarURL,
					presence: presence?.status ?? .offline,
					animate: true
				)
				.padding(6)

				if let fullUser = profile?.user {
					ProfileBadges(user: fullUser, premiumType: profile?.premium_type)
						.frame(minHeight: 40, alignment: .topTrailing)
				}
				Spacer()
				if loadError {
					Image(systemName: "exclamationmark.triangle.fill")
						.font(.system(size: 20))
						.foregroundColor(.orange)
						.help("Failed to get full user profile")
						.padding(.trailing, 14)
				}
			}
			.padding(.leading, 14)
			.padding(.top, -46) // 92/2 = 46
			.padding(.bottom, -8)

			VStack(alignment: .leading, spacing: 6) {
				HStack(alignment: .center, spacing: 6) {
					Group {
						Text(user.username).fontWeight(.bold)
						// Webhooks don't have discriminators
						+ Text(isWebhook ? "" : "#\(user.discriminator)")
							.foregroundColor(.primary.opacity(0.7))
					}.font(.title2).lineLimit(1)
					if user.bot == true || isWebhook {
						NonUserBadge(flags: user.public_flags, isWebhook: isWebhook)
					}
					Spacer()
					Button(action: {
						pasteboard.declareTypes([.string], owner: nil)
						pasteboard.setString("\(user.username)#\(user.discriminator)", forType: .string)
					}, label: {
						Image(systemName: "square.on.square")
					})
					.buttonStyle(.plain)
					.padding()
					.frame(width: 20, height: 20)
				}

				// Custom status
				if let status = presence?.activities.first(where: { $0.type == .custom })?.state {
					Text(status)
						.fixedSize(horizontal: false, vertical: true)
						.padding(.top, 6)
				}

				Divider().padding(.vertical, 6)

				if isWebhook {
					Text("This user is a webhook")
					Button {

					} label: {
						Label("Manage Server Webhooks", systemImage: "link")
							.frame(maxWidth: .infinity)
					}
					.buttonStyle(FlatButtonStyle())
					.controlSize(.small)
				} else {
					if profile == nil, !loadError {
						ProgressView("Loading full profile...")
							.progressViewStyle(.linear)
							.frame(maxWidth: .infinity)
							.tint(.blue)
					}

					if let bio = profile?.user.bio, !bio.isEmpty {
						Text("user.bio").font(.headline).textCase(.uppercase)
						Text(markdown: bio)
							.fixedSize(horizontal: false, vertical: true)
					}

					contentSlot
				}
			}
			.padding(12)
			.background(
				RoundedRectangle(cornerRadius: 4, style: .continuous)
					.fill(colorScheme == .dark ? .black.opacity(0.45) : .white.opacity(0.45))
			)
			.padding(14)
		}
		.frame(width: 300)
	}
}

struct MiniUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        /*MiniUserProfileView()*/
		EmptyView()
    }
}
