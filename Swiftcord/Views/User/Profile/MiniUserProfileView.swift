//
//  MiniUserProfileView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/5/22.
//

import SwiftUI
import DiscordKitCommon
import CachedAsyncImage

struct MiniUserProfileView: View {
	let user: User
	@Binding var profile: UserProfile?
	let guildRoles: [Role]?
	let guildID: Snowflake?
	let isWebhook: Bool
	let loadError: Bool
	let hideNotes: Bool

	@State private var note = ""

	@Environment(\.colorScheme) var colorScheme

    var body: some View {
		let avatarURL = user.avatarURL()

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
				Group {
					if avatarURL.isAnimatable {
						SwiftyGifView(url: avatarURL.modifyingPathExtension("gif"))
					} else {
						CachedAsyncImage(url: avatarURL) { image in
							image.resizable().scaledToFill()
						} placeholder: {
							ProgressView().progressViewStyle(.circular)
						}
					}
				}
				.clipShape(Circle())
				.frame(width: 80, height: 80)
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
				}
				.padding(.bottom, -2)

				Divider().padding(.vertical, 8)

				if isWebhook {
					Text("This user is a webhook")
					Button {

					} label: {
						Label("Manage Server Webhooks", systemImage: "link")
							.frame(maxWidth: .infinity)
					}
					.buttonStyle(.borderedProminent)
					.controlSize(.large)
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
							.padding(.bottom, 8)
					}

					if let profile = profile, guildID != "@me" {
						if let guildRoles = guildRoles {
							let roles = guildRoles.filter {
								profile.guild_member?.roles.contains($0.id) ?? false
							}

							Text(
								profile.guild_member == nil
								? "user.roles.loading"
								: (roles.isEmpty
								   ? "user.roles.none"
								   : (roles.count == 1 ? "user.roles.one" : "user.roles.many")
								)
							)
							.font(.headline)
							.textCase(.uppercase)
							if !roles.isEmpty {
								TagCloudView(content: roles.map({ role in
									HStack(spacing: 6) {
										Circle()
											.fill(Color(hex: role.color))
											.frame(width: 14, height: 14)
											.padding(.leading, 6)
										Text(role.name)
											.font(.system(size: 12))
											.padding(.trailing, 8)
									}
									.frame(height: 24)
									.background(Color.gray.opacity(0.2))
									.cornerRadius(7)
								})).padding(-2)
							}
						} else {
							ProgressView("user.roles.loading")
								.progressViewStyle(.linear)
								.frame(maxWidth: .infinity)
								.tint(.blue)
						}
					}

					if !hideNotes {
						Text("user.note").font(.headline).padding(.top, 8).textCase(.uppercase)
						 // Notes are stored locally for now, but eventually will be synced with the Discord API
						 TextField("Add a note to this user (only visible to you)", text: $note)
							 .textFieldStyle(.roundedBorder)
							 .onChange(of: note) { _ in
								 if note.isEmpty {
									 UserDefaults.standard.removeObject(forKey: "notes.\(user.id)")
								 } else {
									 UserDefaults.standard.set(note, forKey: "notes.\(user.id)")
								 }
							 }
							 .onAppear {
								 note = UserDefaults.standard.string(forKey: "notes.\(user.id)") ?? ""
							 }
					}
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
