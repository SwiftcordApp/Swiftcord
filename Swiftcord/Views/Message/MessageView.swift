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

struct MessageView: View {
    let message: Message
    let shrunk: Bool
    let lineSpacing = 4 as CGFloat
    let quotedMsg: Message?
    let onQuoteClick: (String) -> Void
    
    @State private var hovered = false
    @State private var loadedQuotedMsg: Message? = nil
    @State private var loadQuotedMsgErr = false
    @State private var playLoadAnim = false // Will turn true when first appeared
    
    @EnvironmentObject var serverCtx: ServerContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // This message is a reply!
            if message.message_reference != nil && message.type == .reply {
                HStack(alignment: .center, spacing: 4) {
                    RoundedRectangle(cornerRadius: 5)
                        .trim(from: 0.5, to: 0.75)
                        .stroke(.gray.opacity(0.4), lineWidth: 2)
                        .frame(width: 60, height: 20)
                        .padding(.bottom, -14)
                        .padding(.trailing, -30)
                    Group {
						if let quotedMsg = loadedQuotedMsg ?? quotedMsg, !loadQuotedMsgErr {
							CachedAsyncImage(url: quotedMsg.author.avatarURL()) { phase in
								if let image = phase.image {
									image.resizable().scaledToFill()
								} else if phase.error != nil {
									Image("DiscordIcon").frame(width: 12, height: 12)
								} else { Rectangle().fill(.gray.opacity(0.2)) }
							}
							.clipShape(Circle())
							.frame(width: 16, height: 16)
							Group {
								Text(quotedMsg.author.username)
									.font(.system(size: 14))
									.opacity(0.9)
								Text(quotedMsg.content)
									.font(.system(size: 14))
									.opacity(0.75)
									.lineLimit(1)
							}
							.onTapGesture { onQuoteClick(quotedMsg.id.description) }
							.cursor(NSCursor.pointingHand)
						} else if loadQuotedMsgErr {
							Image(systemName: "xmark.octagon.fill")
								.font(.system(size: 12))
								.frame(width: 16, height: 16)
							Text("Could not load quoted message")
								.font(.system(size: 14))
								.opacity(0.75)
						} else {
							Circle()
								.fill(.gray.opacity(0.2))
								.frame(width: 16, height: 16)
								.onAppear { Task {
									guard message.message_reference!.message_id != nil
									else {
										loadQuotedMsgErr = true
										return
									}

									guard let m = await DiscordAPI.getChannelMsg(
										id: message.message_reference!.channel_id ?? message.channel_id,
										msgID: message.message_reference!.message_id!
									) else {
										loadQuotedMsgErr = true
										return
									}
									loadedQuotedMsg = m
								}}
							Text("Loading message...")
								.font(.system(size: 14))
								.opacity(0.75)
						}
                    }
                    .padding(.bottom, 4)
                    Spacer()
                }.padding(.leading, 20)
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
                    }
                    else {
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
                                if message.author.bot ?? false {
                                    HStack(spacing: 0) {
                                        if ((message.author.public_flags ?? 0) & (1 << 16)) != 0 || message.webhook_id != nil {
                                            Image(systemName: message.webhook_id == nil ? "checkmark" : "link")
                                                .font(.system(size: 8, weight: .heavy))
                                                .frame(width: 15)
                                                .padding(.leading, -3)
                                        }
                                        Text(message.webhook_id == nil
                                            ? "BOT"
                                            : "WEBHOOK"
                                        ).font(.system(size: 10))
                                    }
                                    .frame(height: 15)
                                    .padding(.horizontal, 4)
									.background(Color.accentColor)
                                    .cornerRadius(4)
                                    // .offset(y: -2)
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
                }
                else if message.type == .guildMemberJoin {
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
        .animation(.linear(duration: 0.1), value: hovered)
        .onHover { h in hovered = h }
        .animation(.interpolatingSpring(stiffness: 500, damping: 25), value: playLoadAnim)
        .onAppear(perform: {
            playLoadAnim = true
        })
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
