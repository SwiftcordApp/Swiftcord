//
//  MessageView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//
//  This monstrosity is a view that renders one message

import SwiftUI
import CachedAsyncImage
import DiscordKitCommon
import DiscordKitCore

struct NonUserBadge: View {
	let flags: User.Flags?
	let isWebhook: Bool

	var body: some View {
		HStack(spacing: 0) {
			if let flags = flags, flags.contains(.verifiedBot) {
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

/// Action messages: e.g. member leave, join etc.
struct ActionMessageView: View {
	let message: Message

	private struct ActionMessageData {
		let message: LocalizedStringKey
		let icon: String
		let color: Color
	}

	// Trust, this might seem messy but it's more scalable than putting the
	// views themselves in a huge if tree
	private var data: ActionMessageData {
		switch message.type {
		case .guildMemberJoin:
			return ActionMessageData(
				message: "**\(message.author.username)** joined this server.",
				icon: "arrow.right",
				color: .green
			)
		case .recipientAdd:
			return ActionMessageData(
				message: "**\(message.author.username)** added **\(message.mentions[0].username)** to the group.",
				icon: "arrow.right",
				color: .green
			)
		case .recipientRemove:
			return ActionMessageData(
				message: "**\(message.author.username)** left the group.",
				icon: "arrow.left",
				color: .red
			)
		case .userPremiumGuildSub:
			return ActionMessageData(
				message: "**\(message.author.username)** just boosted the server!",
				icon: "rhombus.fill",
				color: .purple
			)
		case .userPremiumGuildSubTier1:
			return ActionMessageData(
				message: "**\(message.author.username)** just boosted the server! This server has achieved **Level 1!**",
				icon: "rhombus.fill",
				color: .purple
			)
		case .userPremiumGuildSubTier2:
			return ActionMessageData(
				message: "**\(message.author.username)** just boosted the server! This server has achieved **Level 2!**",
				icon: "rhombus.fill",
				color: .purple
			)
		case .userPremiumGuildSubTier3:
			return ActionMessageData(
				message: "**\(message.author.username)** just boosted the server! This server has achieved **Level 3!**",
				icon: "rhombus.fill",
				color: .purple
			)
		default:
			return ActionMessageData(
				message: "Oops, rendering `\(String(describing: message.type))` messages aren't supported yet :(",
				icon: "questionmark",
				color: .gray
			)
		}
	}

	var body: some View {
		Image(systemName: data.icon)
			.foregroundColor(data.color)
			.font(.system(size: 16))
			.padding([.leading, .trailing], 12)
		Group {
			Text(data.message).font(.system(size: 14))
			+ Text(" ").font(.system(size: 14))
			+ Text(DateFormatter.messageDateFormatter.string(from: message.timestamp))
				.font(.system(size: 12))
		}.opacity(0.75)
	}
}

struct MessageView: View {
    let message: Message
    let shrunk: Bool
    let lineSpacing = 4 as CGFloat
    let quotedMsg: Message?
    let onQuoteClick: (Snowflake) -> Void
	let onReply: () -> Void

	@Binding var highlightMsgId: Snowflake?

    @State private var hovered = false
    @State private var loadedQuotedMsg: Message?
    @State private var loadQuotedMsgErr = false

    @EnvironmentObject var serverCtx: ServerContext
	@EnvironmentObject var restAPI: DiscordREST

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
                if message.type == .reply || message.type == .defaultMsg {
                    if !shrunk {
                        UserAvatarView(user: message.author, guildID: serverCtx.guild!.id, webhookID: message.webhook_id, clickDisabled: false)
                    } else {
						Text(message.timestamp, style: .time)
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            .frame(width: 40, height: 22, alignment: .center)
                            .opacity(hovered ? 0.5 : 0)
                    }
                    VStack(alignment: .leading, spacing: lineSpacing) {
                        if !shrunk {
                            HStack(spacing: 6) {
                                Text(message.member?.nick ?? message.author.username)
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
								if message.author.bot ?? false || message.webhook_id != nil {
									// No idea what's the difference between flags and public_flags,
									// just try both to see which is present
									NonUserBadge(
										flags: message.author.flags ?? message.author.public_flags,
										isWebhook: message.webhook_id != nil
									)
                                }
								HStack(spacing: 0) {
									Text(DateFormatter.messageDateFormatter.string(from: message.timestamp))
									if let edited_timestamp = message.edited_timestamp {
										Text("message.edited")
										Text(edited_timestamp, style: .time)
									}
								}
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
								let msg = message.content.containsOnlyEmojiAndSpaces
									? message.content.replacingOccurrences(of: " ", with: " ")
									: message.content
                                Group {
									Text(markdown: msg)
									.font(.system(
										size: message.content.containsOnlyEmojiAndSpaces ? 48 : 15
									)) +
                                    Text(
										message.edited_timestamp != nil && shrunk
                                         ? "message.edited.shrunk"
                                         : ""
									)
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
				} else {
					ActionMessageView(message: message)
				}
                Spacer()
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 48)
        .padding(.vertical, lineSpacing / 2)
        .background(hovered ? .gray.opacity(0.07) : .clear)
		.background(
			Rectangle()
				.fill(.blue)
				.opacity(highlightMsgId == message.id ? 0.2 : 0)
				.animation(.easeIn(duration: 0.25), value: highlightMsgId == message.id)
		)
        .padding(.top, shrunk ? 0 : 16 - lineSpacing / 2)
        .onHover { isHovered in hovered = isHovered }
        .contextMenu {
			Button {
				onReply()
			} label: {
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
}

private extension MessageView {
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
			await restAPI.deleteMsg(id: message.channel_id, msgID: message.id)
		}
	}

	func copyLink() {
		if let guildID = serverCtx.guild?.id, let channelID = serverCtx.channel?.id {
			let pasteboard = NSPasteboard.general
			pasteboard.clearContents()
			pasteboard.setString(
				"https://canary.discord.com/channels/\(guildID)/\(channelID)/\(message.id)",
				forType: .string
			)
		}
	}

	func copyID() {
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		pasteboard.setString(message.id, forType: .string)
	}
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        Text("TODO")
        // MessageView()
    }
}
