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
						let after = String(msg[end..<msg.endIndex])
							.replacingOccurrences(of: "```", with: "")
						Text(markdown: before)
						ForEach(backticksRanges.indices, id: \.self) { i in
							if i % 2 == 1 { // odd indices represent code sections
								let start = backticksRanges[i-1].upperBound
								let end = backticksRanges[i].lowerBound
								let code = String(msg[start..<end]).trimmingCharacters(in: .whitespacesAndNewlines)
								Text(code)
									.padding()
									.background(Color.black.opacity(0.3))
									.foregroundColor(.white)
									.cornerRadius(10)
							} else { // even indices represent non-code sections
								let start = i == 0 ? msg.startIndex : backticksRanges[i-1].upperBound
								let end = i == backticksRanges.count-1 ? msg.endIndex : backticksRanges[i].lowerBound
								let nonCode = String(msg[start..<end])
								Text(markdown: nonCode)
							}
						}
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
