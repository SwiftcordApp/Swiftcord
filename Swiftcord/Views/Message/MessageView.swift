//
//  MessageView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//
//  This monstrosity is a view that renders one message

import SwiftUI
import CachedAsyncImage
import DiscordKit

struct NonUserBadge: View {
	let flags: Int?
	let isWebhook: Bool

	var body: some View {
		HStack(spacing: 0) {
			if let flags = flags, flags & 65536 != 0 {
				Image(systemName: "checkmark")
					.font(.system(size: 8, weight: .heavy))
					.frame(width: 15)
					.padding(.leading, -3)
			}
			Text(isWebhook
				? "WEBHOOK"
				: "BOT"
			).font(.system(size: 10))
		}
		.frame(height: 15)
		.padding(.horizontal, 4)
		.background(Color.accentColor)
		.cornerRadius(4)
	}
}

struct MessageView: View, Equatable {
    let message: Message
    let shrunk: Bool
    let lineSpacing = 4 as CGFloat
    let quotedMsg: Message?
    let onQuoteClick: (String) -> Void

    @State private var hovered = false
    @State private var loadedQuotedMsg: Message?
    @State private var loadQuotedMsgErr = false

    @EnvironmentObject var serverCtx: ServerContext

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // This message is a reply!
            if message.type == .reply {
				ReferenceMessageView(referencedMsg: message.referenced_message)
					.onTapGesture { if let referencedID = message.referenced_message?.id {
						onQuoteClick(referencedID)
					}}
            }
            HStack(
                alignment: message.type == .guildMemberJoin || message.type == .userPremiumGuildSub ? .center : .top,
                spacing: 16
            ) {
                // Would have loved to use switch-case but fallthrough doesn't work :(
                let timestring = message.timestamp.toDate()?.toTimeString() ?? ""
                if message.type == .reply || message.type == .defaultMsg {
                    if !shrunk {
                        UserAvatarView(user: message.author, guildID: serverCtx.guild!.id, webhookID: message.webhook_id, clickDisabled: false)
                    } else {
                        Text(timestring)
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            .frame(width: 40, height: 22, alignment: .center)
                            .animation(.linear(duration: 0.1), value: hovered)
                            .opacity(hovered ? 0.5 : 0)
                    }
                    VStack(alignment: .leading, spacing: lineSpacing) {
                        if !shrunk {
                            HStack(spacing: 6) {
                                Text(message.member?.nick ?? message.author.username)
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
								if message.author.bot ?? false || message.webhook_id != nil {
									NonUserBadge(flags: message.author.public_flags, isWebhook: message.webhook_id != nil)
                                }
                                Text(timestring + (message.edited_timestamp != nil ? " • Edited: \(message.edited_timestamp!.toDate()?.toTimeString() ?? "")" : ""))
                                    .font(.system(size: 12))
                                    .opacity(0.5)
                            }
                        }
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
                                Group {
                                    Text(.init(message.content.replacingOccurrences(
                                        of: " ",
                                        with: message.content.containsOnlyEmojiAndSpaces ? " " : " "
                                    ))).font(.system(
                                        size: message.content.containsOnlyEmojiAndSpaces ? 48 : 15
                                    )) +
                                    Text(message.edited_timestamp != nil && shrunk
                                         ? " (edited)"
                                         : "")
                                        .font(.system(size: 8))
                                        .italic()
                                        .foregroundColor(Color(NSColor.textColor).opacity(0.4))
                                }.textSelection(.enabled)
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
                } else if message.type == .guildMemberJoin {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 16))
                        .padding([.leading, .trailing], 12)
                    Text("Welcome, \(message.author.username), enjoy your stay!")
                        .font(.system(size: 14)).opacity(0.5)
                }
                Spacer()
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 48)
        .padding(.vertical, lineSpacing / 2)
        .background(hovered ? .gray.opacity(0.07) : .clear)
        .padding(.top, shrunk ? 0 : 16 - lineSpacing / 2)
        .onHover { isHovered in hovered = isHovered }
        .contextMenu {
			Button(action: reply) {
                // Using Label(_:systemImage:) doesn't show image on macOS
                Image(systemName: "arrowshape.turn.up.left.fill")
                Text("Reply")
            }

			Divider()

            Group {
				Button(action: addReaction) {
                    Image(systemName: "face.smiling.fill")
                    Text("Add Reaction")
                }
				Button(action: createThread) {
                    Image(systemName: "number")
                    Text("Create Thread")
                }
				Button(action: pinMessage) {
                    Image(systemName: "pin.fill")
                    Text("Pin Message")
                }
            }

            Divider()

			Group {
				Button(action: editMessage) {
					Image(systemName: "pencil")
					Text("Edit")
				}
				Button(role: .destructive, action: deleteMessage) {
					Image(systemName: "xmark.bin.fill")
					Text("Delete Message").foregroundColor(.red)
				}
			}

            Divider()

			Group {
				Button(action: copyLink) {
					Image(systemName: "link")
					Text("Copy Link")
				}
				Button(action: copyID) {
					Image(systemName: "number.circle.fill")
					Text("Copy ID")
				}
			}
        }
	}

	static func == (lhs: MessageView, rhs: MessageView) -> Bool {
		lhs.message == rhs.message
	}
}

private extension MessageView {
	func reply() {
		print(#function)
	}

	func addReaction() {
		print(#function)
	}

	func createThread() {
		print(#function)
	}

	func pinMessage() {
		print(#function)
	}

	func editMessage() {
		print(#function)
	}

	func deleteMessage() {
		Task {
			await DiscordAPI.deleteMsg(id: message.channel_id, msgID: message.id)
		}
	}

	func copyLink() {
		print(#function)
	}

	func copyID() {
		NSPasteboard.general.setString(message.id.description, forType: .string)
	}
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        Text("TODO")
        // MessageView()
    }
}
