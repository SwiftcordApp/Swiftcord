//
//  DefaultMessageView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 11/8/22.
//

import SwiftUI
import DiscordKitCore
import MarkdownUI

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
				
				Markdown(msg)
					.font(.appMessage)
					.markdownBlockStyle(\.codeBlock, body: { configuration in
						configuration.label
							.markdownTextStyle {
								FontFamilyVariant(.monospaced)
								FontSize(.em(0.8))
							}
							.padding(16)
							.background(.codeBlock)
							.foregroundStyle(.primary)
							.markdownMargin(top: 0, bottom: 16)
							.fixedSize(horizontal: false, vertical: true)
							.clipShape(RoundedRectangle(cornerRadius: 10))
					})
					.markdownTextStyle(\.code) {
						FontFamilyVariant(.monospaced)
						FontSize(Font.appMessageFontSize)
						ForegroundColor(.purple)
						BackgroundColor(.purple.opacity(0.25))
					}
					.markdownTextStyle(\.text) {
						FontProperties(
							family: .system(Font.fontDesign),
							familyVariant: .normal,
							capsVariant: .normal,
							digitVariant: .normal,
							style: .normal,
							weight: .regular,
							size: message.content.containsOnlyEmojiAndSpaces ? 48 : Font.appMessageFontSize
						)
					}
					.lineSpacing(4)
					.textSelection(.enabled)
				
				if message.edited_timestamp != nil && shrunk {
					Text("message.edited.shrunk")
						.font(.callout)
						.foregroundStyle(Color(nsColor: .textColor).opacity(0.4))
				}
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
