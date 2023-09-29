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

struct UserAvatarView: View {
    let user: User
    let guildID: Snowflake?
    let webhookID: Snowflake?
	var size: CGFloat = 40
	@State private var fullUser: User?
	@State private var member: Member?
    @State private var infoPresenting = false
	@State private var loadFullFailed = false
	@State private var note = ""

	@EnvironmentObject var ctx: ServerContext
	@EnvironmentObject var gateway: DiscordGateway

	private static let profileCache = Cache<ProfileKey, (User, Member?)>()

    var body: some View {
		// _ = print("render!")
		let avatarURL = user.avatarURL(size: size == 40 ? 160 : Int(size)*2)
	    // This is actually crucial to resolve a SwiftUI bug preventing a required rerender when this property changes
		let _ = member // swiftlint:disable:this redundant_discardable_let

		Button {
			if user.id == gateway.cache.user?.id, fullUser == nil {
				fullUser = User(from: gateway.cache.user!)
			}

			if let (cUser, cMember) = Self.profileCache[ProfileKey(guildID: guildID, userID: user.id)] {
				member = cMember
				fullUser = cUser
			}

			infoPresenting.toggle()
			AnalyticsWrapper.event(type: .openPopout, properties: [
				"type": "Profile Popout",
				"other_user_id": user.id
			])

			if let guildID = guildID, guildID != "@me" {
				gateway.requestPresence(id: guildID, memberID: user.id)
			}

			// Get user profile for a fuller User object and roles
			if member == nil || fullUser == nil, webhookID == nil, guildID != "@me" {
				Task {
					do {
						let profile = try await restAPI.getProfile(
							user: user.id,
							guildID: guildID == "@me" ? nil : guildID
						)
						member = profile.guild_member
						fullUser = profile.user
						Self.profileCache[ProfileKey(guildID: guildID, userID: user.id)] = (profile.user, profile.guild_member)
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
				user: fullUser ?? user,
				member: member,
				guildRoles: ctx.roles,
				isWebhook: webhookID != nil,
				loadError: loadFullFailed
			) {
				if member == nil, !loadFullFailed {
					ProgressView("Loading full profile...")
						.progressViewStyle(.linear)
						.frame(maxWidth: .infinity)
						.tint(.blue)
				}

				Text(ctx.guild?.id.isDM == true ? "Discord Member Since" : "Member Since")
					.font(.headline)
					.textCase(.uppercase)
				HStack(spacing: 8) {
					Image("DiscordIcon").resizable().aspectRatio(contentMode: .fit).frame(width: 16)
					Text(user.id.createdAt?.formatted(.dateTime.day().month().year()) ?? "Unknown")

					if let guild = ctx.guild, !guild.id.isDM {
						Circle().fill(Color(nsColor: .separatorColor)).frame(width: 4, height: 4)

						if let iconURL = guild.properties.iconURL(size: 32), let url = URL(string: iconURL) {
							BetterImageView(url: url).frame(width: 16).clipShape(Circle())
						} else {
							Text("\(guild.properties.name)")
								.font(.caption)
								.fixedSize()
								.frame(width: 16, height: 16, alignment: .leading)
								.background(.gray.opacity(0.5))
								.clipShape(Circle())
						}
						Text(member?.joined_at.formatted(.dateTime.day().month().year()) ?? "Unknown")
					}
				}

				if guildID != "@me" {
					let guildRoles = ctx.roles
					let roles = guildRoles.filter {
						member?.roles.contains($0.id) ?? false
					}

					Text(
						member == nil
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

	/*static func == (lhs: UserAvatarView, rhs: UserAvatarView) -> Bool {
		lhs.user.id == rhs.user.id && lhs.profile?.user.id == rhs.profile?.user.id
	}*/
}
