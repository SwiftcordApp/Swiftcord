//
//  UserAvatarView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import CachedAsyncImage
import DiscordKit

struct UserAvatarView: View {
    let user: User
    let guildID: Snowflake
    let webhookID: Snowflake?
    let clickDisabled: Bool
    @State private var profile: UserProfile? // Lazy-loaded full user
    @State private var guildRoles: [Role]? // Lazy-loaded guild roles
    @State private var infoPresenting = false
	@State private var loadFullFailed = false

    var body: some View {
        let avatarURL = user.avatarURL()

        CachedAsyncImage(url: avatarURL) { image in
            image.resizable().scaledToFill()
        } placeholder: { Rectangle().fill(.gray.opacity(0.2)) }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
        .onTapGesture {
            infoPresenting.toggle()

			guard !clickDisabled else { return }
			// Get user profile for a fuller User object
			if profile == nil && webhookID == nil { Task {
				profile = await DiscordAPI.getProfile(
					user: user.id,
					guildID: guildID == "@me" ? nil : guildID
				)
				guard profile != nil else { // Profile is still nil: fetching failed
					loadFullFailed = true
					return
				}
			}}
			if guildRoles == nil, webhookID == nil, guildID != "@me" { Task {
				guildRoles = await DiscordAPI.getGuildRoles(id: guildID)
				// print(guildRoles)
			}}
        }
        .cursor(NSCursor.pointingHand)
        .popover(isPresented: $infoPresenting, arrowEdge: .trailing) {
            MiniUserProfileView(
				user: user,
				profile: profile,
				guildRoles: guildRoles,
				guildID: guildID,
				isWebhook: webhookID != nil,
				loadError: loadFullFailed
			)
        }
	}
}

struct UserAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        // UserAvatarView()
        Text("TODO")
    }
}
