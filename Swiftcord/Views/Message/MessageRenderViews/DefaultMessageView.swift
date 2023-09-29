//
//  DefaultMessageView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 11/8/22.
//

import SwiftUI
import DiscordKitCore

struct DefaultMessageView: View {
	let message: Message
	let shrunk: Bool

    var body: some View {
		// For including additional message components
		VStack(alignment: .leading, spacing: 4) {
			if !message.content.isEmpty {
				// Guard doesn't work in a view :(((
				/*if let msg = attributedMessage(content: message.content) {
				 Text(msg)
				 .font(.system(size: 15))
				 .textSelection(.enabled)
				 // fix this poor implementation later
				 }*/
				let msg = message.content.containsOnlyEmojiAndSpaces
				? message.content.replacingOccurrences(of: " ", with: " ")
				: message.content
				Group {
					Text(markdown: msg)
						.font(.system(size: message.content.containsOnlyEmojiAndSpaces ? 48 : 15))
					+ Text(
						message.edited_timestamp != nil && shrunk
						? "message.edited.shrunk"
						: ""
					)
					.font(.system(size: 8))
					.italic()
					.foregroundColor(Color(NSColor.textColor).opacity(0.4))
				}
				.lineSpacing(4)
				.textSelection(.enabled)
			}
			if let stickerItems = message.sticker_items {
				ForEach(stickerItems) { sticker in
					MessageStickerView(sticker: sticker)
				}
			}
			ForEach(message.attachments) { attachment in
				AttachmentView(attachment: attachment)
			}
			ForEach(message.embeds) { embed in
				EmbedView(embed: embed)
			}
		}
    }
}
