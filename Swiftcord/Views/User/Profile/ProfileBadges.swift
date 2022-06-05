//
//  ProfileBadges.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 30/5/22.
//

import DiscordKit
import DiscordKitCore
import SwiftUI

struct ProfileBadges: View, Equatable {
	let user: User

	internal static let badgeMapping: [User.Flags: String] = [
		.staff: "DiscordStaff",
		.bugHunterLevel1: "BugHunter",
		.bugHunterLevel2: "BugHunter",
		.certifiedModerator: "CertifiedModerator",
		.premiumEarlySupporter: "EarlySupporter",
		.hypesquad: "HypesquadEvents",
		.hypesquadOnlineHouse3: "HypesquadBalance",
		.hypesquadOnlineHouse1: "HypesquadBravery",
		.hypesquadOnlineHouse2: "HypesquadBrilliance",
		.verifiedDeveloper: "EarlyVerifiedBotDev"
	]

	var body: some View {
		if let flags = user.flags {
			let flagArray = User.Flags.allCases.filter { flags.contains($0) }
			TagCloudView(content: flagArray.map { flag in
				Group {
					if let badge = ProfileBadges.badgeMapping[flag] {
						Image(badge).frame(width: 22, height: 22)
							.help(flag.description)
					}

					if let premiumType = user.premium_type, premiumType != .none {
						Image("NitroSubscriber").frame(width: 22, height: 22)
							.help(premiumType.description)
					}
				}
			}).padding(-2)
		}
	}

	static func == (lhs: ProfileBadges, rhs: ProfileBadges) -> Bool {
		return lhs.user.premium_type == rhs.user.premium_type &&
			lhs.user.flags == rhs.user.flags
	}
}
