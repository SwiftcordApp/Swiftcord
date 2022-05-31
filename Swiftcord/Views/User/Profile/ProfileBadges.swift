//
//  ProfileBadges.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 30/5/22.
//

import SwiftUI
import DiscordKit

struct ProfileBadges: View, Equatable {
	let user: User

	internal static let badgeMapping: [UserFlags: String] = [
		.staff: "DiscordStaff",
		.bugHunterLv1: "BugHunter",
		.bugHunterLv2: "BugHunter",
		.certifiedMod: "CertifiedModerator",
		.earlySupporter: "EarlySupporter",
		.hypesquadEvents: "HypesquadEvents",
		.hypesquadBalance: "HypesquadBalance",
		.hypesquadBravery: "HypesquadBravery",
		.hypesquadBrilliance: "HypesquadBrilliance",
		.verifiedDev: "EarlyVerifiedBotDev",
		.premium: "NitroSubscriber"
	]

    var body: some View {
		if let flags = user.flagsArr {
			TagCloudView(content: flags.map { flag in
				Group {
					if let badge = ProfileBadges.badgeMapping[flag] {
						Image(badge).frame(width: 22, height: 22)
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
