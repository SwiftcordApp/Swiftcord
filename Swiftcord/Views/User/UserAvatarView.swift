//
//  UserAvatarView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import CachedAsyncImage
import DiscordKit

struct UserAvatarView: View, Equatable {
    let user: User
    let guildID: Snowflake
    let webhookID: Snowflake?
    let clickDisabled: Bool
    @State private var profile: UserProfile? // Lazy-loaded full user
    @State private var infoPresenting = false
	@State private var loadFullFailed = false

	@EnvironmentObject var ctx: ServerContext
	@EnvironmentObject var gateway: DiscordGateway

    var body: some View {
        let avatarURL = user.avatarURL()

        CachedAsyncImage(url: avatarURL) { image in
            image.resizable().scaledToFill()
        } placeholder: { Rectangle().fill(.gray.opacity(0.2)) }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
        .onTapGesture {
			guard !clickDisabled else { return }

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

			infoPresenting.toggle()

			// Get user profile for a fuller User object and roles
			if profile?.guild_member == nil, webhookID == nil,
			   guildID != "@me" || profile?.user == nil { Task {
				guard let loadedProfile = await DiscordAPI.getProfile(
					user: user.id,
					guildID: guildID == "@me" ? nil : guildID
				) else { // Profile is still nil: fetching failed
					loadFullFailed = true
					return
				}
				profile = loadedProfile
			}}
        }
        .cursor(NSCursor.pointingHand)
        .popover(isPresented: $infoPresenting, arrowEdge: .trailing) {
            MiniUserProfileView(
				user: user,
				profile: profile,
				guildRoles: ctx.roles,
				guildID: guildID,
				isWebhook: webhookID != nil,
				loadError: loadFullFailed,
				hideNotes: false
			)
        }
	}

	static func == (lhs: UserAvatarView, rhs: UserAvatarView) -> Bool {
		return lhs.user == rhs.user &&
		lhs.profile?.user == rhs.profile?.user &&
		lhs.profile?.guild_member?.user == rhs.profile?.guild_member?.user &&
		lhs.infoPresenting == rhs.infoPresenting &&
		lhs.loadFullFailed == rhs.loadFullFailed
	}
}
