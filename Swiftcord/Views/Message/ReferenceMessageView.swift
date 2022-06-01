//
//  ReferencedMessageView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 31/5/22.
//

import SwiftUI
import DiscordKit
import CachedAsyncImage

struct ReferenceMessageView: View {
	let referencedMsg: PartialMessage?

	@EnvironmentObject var serverCtx: ServerContext

    var body: some View {
		HStack(alignment: .center, spacing: 4) {
			RoundedRectangle(cornerRadius: 5)
				.trim(from: 0.5, to: 0.75)
				.stroke(.gray.opacity(0.4), lineWidth: 2)
				.frame(width: 60, height: 20)
				.padding(.bottom, -14)
				.padding(.trailing, -30)

			Group {
				if let quotedMsg = referencedMsg {
					UserAvatarView(
						user: quotedMsg.author!,
						guildID: serverCtx.guild?.id,
						webhookID: quotedMsg.webhook_id,
						size: 16
					)

					Group {
						Text(quotedMsg.author!.username)
							.font(.system(size: 14))
							.opacity(0.9)

						if quotedMsg.author?.bot == true || quotedMsg.webhook_id != nil {
							NonUserBadge(
								flags: quotedMsg.author?.flags?.rawValue,
								isWebhook: quotedMsg.webhook_id != nil
							)
						}

						Text((quotedMsg.content!.isEmpty)
							 ? "Click to see attachment"
							 : .init(quotedMsg.content!.replacingOccurrences(of: "\n", with: " "))
						)
						.font(quotedMsg.content!.isEmpty
							  ? .system(size: 14).italic() : .system(size: 14))
						.opacity(0.75)
						.lineLimit(1)

						if !quotedMsg.attachments!.isEmpty || !quotedMsg.embeds!.isEmpty {
							Image(systemName: "photo.fill").font(.system(size: 16)).opacity(0.75)
						}
					}
					.cursor(NSCursor.pointingHand)
				} else {
					Image(systemName: "arrowshape.turn.up.left.circle.fill")
						.font(.system(size: 16))
						.frame(width: 16, height: 16)

					Text("Original message was deleted.")
						.italic()
						.font(.system(size: 14))
						.opacity(0.75)
				}
			}
			.padding(.bottom, 4)
			Spacer()
		}
		.padding(.leading, 20)
    }
}
