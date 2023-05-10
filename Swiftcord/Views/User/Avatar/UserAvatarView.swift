//
//  UserAvatarView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import CachedAsyncImage
import DiscordKitCore
import DiscordKit

struct ProfileKey: Hashable {
	let guildID: Snowflake?
	let userID: Snowflake
}

private let profileCache = Cache<ProfileKey, UserProfile>()

struct UserAvatarView: View, Equatable {
    let user: User
    let guildID: Snowflake?
    let webhookID: Snowflake?
	var size: CGFloat = 40
    @State private var profile: UserProfile? // Lazy-loaded full user
    @State private var infoPresenting = false
	@State private var loadFullFailed = false
	@State private var note = ""

	@EnvironmentObject var ctx: ServerContext
	@EnvironmentObject var gateway: DiscordGateway

    var body: some View {
		// _ = print("render!")
		let avatarURL = user.avatarURL(size: size == 40 ? 160 : Int(size)*2)

		Button {
			if user.id == gateway.cache.user?.id, profile == nil {
				profile = UserProfile(
					connected_accounts: [],
					guild_member: nil,
					premium_guild_since: nil,
					premium_since: nil,
					mutual_guilds: nil,
					user: User(from: gateway.cache.user!)
				)
			}

			if let cached = profileCache[ProfileKey(guildID: guildID, userID: user.id)] { profile = cached }

			infoPresenting.toggle()
			AnalyticsWrapper.event(type: .openPopout, properties: [
				"type": "Profile Popout",
				"other_user_id": user.id
			])

			if let guildID = guildID, guildID != "@me" {
				gateway.requestPresence(id: guildID, memberID: user.id)
			}

			// Get user profile for a fuller User object and roles
			if profile?.guild_member == nil, webhookID == nil, guildID != "@me" || profile?.user == nil {
				Task {
					do {
						profile = try await restAPI.getProfile(
							user: user.id,
							guildID: guildID == "@me" ? nil : guildID
						)
						profileCache[ProfileKey(guildID: guildID, userID: user.id)] = profile
					} catch {
						loadFullFailed = true
					}
				}
			}
		} label: {
			BetterImageView(url: avatarURL)
				.frame(width: size, height: size)
				.clipShape(Circle())
		}
		.buttonStyle(.borderless)
		.popover(isPresented: $infoPresenting, arrowEdge: .trailing) {
			MiniUserProfileView(
				user: user,
				profile: $profile,
				guildRoles: ctx.roles,
				isWebhook: webhookID != nil,
				loadError: loadFullFailed
			) {
				if let profile = profile, guildID != "@me" {
					let guildRoles = ctx.roles
					let roles = guildRoles.filter {
						profile.guild_member?.roles.contains($0.id) ?? false
					}

					Text(
						profile.guild_member == nil
						? "user.roles.loading"
						: (roles.isEmpty ? "user.roles.none" : (roles.count == 1 ? "user.roles.one" : "user.roles.many"))
					)
					.font(.headline)
					.textCase(.uppercase)
					.padding(.top, 6)
					if !roles.isEmpty {
						TagCloudView(
							content: roles.map { role in
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
								.background(.gray.opacity(0.2))
								.cornerRadius(7)
							}
						).padding(-2)
					}
				}
				Text("user.note")
					.font(.headline)
					.textCase(.uppercase)
					.padding(.top, 6)
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

	static func == (lhs: UserAvatarView, rhs: UserAvatarView) -> Bool {
		lhs.user.id == rhs.user.id
	}
}
