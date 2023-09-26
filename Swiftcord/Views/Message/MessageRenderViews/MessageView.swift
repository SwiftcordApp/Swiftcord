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
			Text(isWebhook ? "Webhook" : "Bot")
                .font(.system(size: 10))
                .textCase(.uppercase)
		}
		.frame(height: 15)
		.padding(.horizontal, 4)
		.background(Color.accentColor)
		.cornerRadius(4)
	}
}

struct MessageView: View, Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.message == rhs.message
        // && lhs.message.embeds == rhs.message.embeds
    }

    let message: Message
    let shrunk: Bool
    let quotedMsg: Message?
    let onQuoteClick: (Snowflake) -> Void

	@Binding var replying: MessagesViewModel.ReplyRef?
	@Binding var highlightMsgId: Snowflake?

    @State private var hovered = false
    @State private var loadedQuotedMsg: Message?
    @State private var loadQuotedMsgErr = false

    @EnvironmentObject var serverCtx: ServerContext
    @EnvironmentObject var gateway: DiscordGateway

	// The spacing between lines of text, used to compute padding and line height
	static let lineSpacing: CGFloat = 4

	// Messages that can be rendered as "default" messages
	static let defaultTypes: [MessageType] = [.defaultMsg, .reply]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // This message is a reply!
            if message.type == .reply {
				ReferenceMessageView(referencedMsg: message.referenced_message).onTapGesture {
					if let referencedID = message.referenced_message?.id {
						onQuoteClick(referencedID)
					}
				}
            }
            HStack(
                alignment: MessageView.defaultTypes.contains(message.type) ? .top : .center,
                spacing: 16
            ) {
                if MessageView.defaultTypes.contains(message.type) {
                    if !shrunk {
                        UserAvatarView(user: message.author, guildID: serverCtx.guild!.id, webhookID: message.webhook_id)
                    } else {
						Text(message.timestamp, style: .time)
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            .frame(width: 40, height: 22, alignment: .center)
                            .opacity(hovered ? 0.5 : 0)
                    }
					VStack(alignment: .leading, spacing: Self.lineSpacing) {
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
						DefaultMessageView(message: message, shrunk: shrunk)
                    }
				} else {
					ActionMessageView(message: message, mini: false)
				}
                Spacer()
            }
        }
        .padding(.trailing, 32)
		.padding(.vertical, Self.lineSpacing / 2)
		.background(
			Rectangle()
				.fill(.blue)
				.opacity(highlightMsgId == message.id ? 0.2 : 0)
				.animation(.easeIn(duration: 0.25), value: highlightMsgId == message.id)
		)
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
				if message.author.id == gateway.cache.user?.id {
					Button(action: editMessage) {
						Image(systemName: "pencil")
						Text("Edit")
					}
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
	func reply() {
		withAnimation {
			replying = .init(
				messageID: message.id,
				guildID: serverCtx.guild!.id,
				ping: true,
				authorID: message.author.id,
				authorUsername: message.author.username
			)
		}
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
			try? await restAPI.deleteMsg(id: message.channel_id, msgID: message.id)
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

/*struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        //MessageView()
    }
}*/
