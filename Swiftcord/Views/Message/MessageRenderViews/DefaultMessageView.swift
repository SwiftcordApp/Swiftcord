//
//  DefaultMessageView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 11/8/22.
//

import SwiftUI
import DiscordKitCommon

struct DefaultMessageView: View {
	let message: Message
	let shrunk: Bool
	
	var body: some View {
		// For including additional message components
		VStack(alignment: .leading, spacing: 4) {
			if !message.content.isEmpty {
				let msg = message.content.containsOnlyEmojiAndSpaces
				? message.content.replacingOccurrences(of: " ", with: " ")
				: message.content
				let backticksRanges = msg.ranges(of: "```")
				Group {
					if backticksRanges.count >= 2 {
						let start = backticksRanges[0].upperBound
						let end = backticksRanges[backticksRanges.count-1].lowerBound
						let before = String(msg[msg.startIndex..<start])
							.replacingOccurrences(of: "```", with: "")
						let code = String(msg[start..<end]).trimmingCharacters(in: .whitespacesAndNewlines)
						let after = String(msg[end..<msg.endIndex])
							.replacingOccurrences(of: "```", with: "")
						Text(markdown: before)
						Text(markdown: code)
							.padding()
							.background(Color.black.opacity(0.3))
							.foregroundColor(.white)
							.cornerRadius(10)
						Text(markdown: after)
					} else {
						Text(markdown: msg)
					}
				}
				.font(.system(size: message.content.containsOnlyEmojiAndSpaces ? 48 : 15))
				.lineSpacing(3)
				.textSelection(.enabled)
			}
			
			if let stickerItems = message.sticker_items {
				ForEach(stickerItems) { sticker in
					StickerView(sticker: sticker)
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
