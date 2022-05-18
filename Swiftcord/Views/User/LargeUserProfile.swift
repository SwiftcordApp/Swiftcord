//
//  LargeUserProfile.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI
import CachedAsyncImage
import DiscordKit

struct LargeUserProfile<Content: View>: View {
    let user: User
    @ViewBuilder var slot: Content
    
    @State private var selectorIndex = 0
    
    let badgeMapping: [UserFlags: String] = [
        .staff: "DiscordStaff",
        .bugHunterLv1: "BugHunter",
        .bugHunterLv2: "BugHunter",
        .certifiedMod: "CertifiedModerator",
        .earlySupporter: "EarlySupporter",
        .hypesquadEvents: "HypesquadEvents",
        .hypesquadBalance: "HypesquadBalance",
        .hypesquadBravery: "HypesquadBravery",
        .hypesquadBrilliance: "HypesquadBrilliance",
        .verifiedDev: "EarlyVerifiedBotDev"
    ]
    
    var body: some View {
        let avatarURL = user.avatarURL(size: 240)
        
        VStack(alignment: .leading, spacing: 0) {
            if let accentColor = user.accent_color {
                Rectangle().fill(Color(hex: accentColor))
                    .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
            }
            else {
                CachedAsyncImage(url: avatarURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: { ProgressView().progressViewStyle(.circular)}
                .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                .blur(radius: 12)
                .clipped()
            }
            HStack(alignment: .bottom, spacing: 12) {
                ZStack {
                    Circle()
                        .trim(from: 0.5, to: 1)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .frame(width: 136, height: 136)
                    CachedAsyncImage(url: avatarURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView().progressViewStyle(.circular)
                    }
                    .background(.black)
                    .clipShape(Circle())
                    .frame(width: 120, height: 120)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        Text(user.username) +
                        Text("#" + user.discriminator)
                            .foregroundColor(Color(NSColor.textColor).opacity(0.75))
                    }
                    .font(.title2)
                    HStack {
                        ForEach(user.flagsArr!, id: \.self) { f in
                            if let badge = badgeMapping[f] { Image(badge).frame(width: 22, height: 22) }
                        }
                        if (user.premium_type ?? 0) != 0 { // nil != 0
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
