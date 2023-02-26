//
//  MessageInputReplyView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 11/8/22.
//

import SwiftUI
import DiscordKit
import DiscordKitCore

struct MessageInputReplyView: View {
	@Binding var replying: MessagesViewModel.ReplyRef?

	@EnvironmentObject var gateway: DiscordGateway

    var body: some View {
		if let replyingRef = replying {
			HStack(spacing: 12) {
				Text("Replying to **\(replyingRef.authorUsername)**")

				Spacer()

				if replyingRef.authorID != gateway.cache.user?.id {
					Button {
						withAnimation {
							replying = .init(
								messageID: replyingRef.messageID,
								guildID: replyingRef.guildID,
								ping: !replyingRef.ping,
								authorID: replyingRef.authorID,
								authorUsername: replyingRef.authorUsername
							)
						}
					} label: {
						Label(replyingRef.ping ? "On" : "Off", systemImage: "at")
							.foregroundColor(replyingRef.ping ? .blue : .gray)
							.font(.system(size: 14, weight: .bold))
					}.buttonStyle(.plain)

					Divider()
				}

				Button {
					withAnimation {
						replying = nil
					}
				} label: {
					Image(systemName: "x.circle.fill").font(.system(size: 16))
				}.buttonStyle(.plain)
			}
			.fixedSize(horizontal: false, vertical: true)
			.padding(.horizontal, 16)
			.padding(.vertical, 8)
			.background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
		}
    }
}
