//
//  ProfileBadges.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 30/5/22.
//

import DiscordKitCore
import SwiftUI

struct ProfileBadges: View, Equatable {
    let user: User
    let premiumType: User.PremiumType?

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
        .verifiedDeveloper: "EarlyVerifiedBotDev",
        .activeDeveloper: "ActiveDeveloper"
    ]

    var isPremium: Bool {
        if let premiumType = premiumType ?? user.premium_type, premiumType != .none { return true }
        return false
    }

    var body: some View {
        if let flags = user.flags {
            let flagArray = User.Flags.allCases.filter { flags.contains($0) }
                + (isPremium ? [User.Flags.premiumEarlySupporter] : []) // Dummy flag for nitro
            TagCloudView(content: flagArray.enumerated().map { (idx, flag) in
                Group {
                    if isPremium, idx == flagArray.count - 1 {
                        Image("NitroSubscriber").frame(width: 22, height: 22)
                            .help(user.premium_type?.description ?? "")
                    } else if let badge = ProfileBadges.badgeMapping[flag] {
                        Image(badge).frame(width: 22, height: 22)
                            .help(flag.description)
                    }
                }
            }).padding(-2)
        }
    }

    static func == (lhs: ProfileBadges, rhs: ProfileBadges) -> Bool {
        lhs.user.premium_type == rhs.user.premium_type
            && lhs.user.flags == rhs.user.flags
    }
}
