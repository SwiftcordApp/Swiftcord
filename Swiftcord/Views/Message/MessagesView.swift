//
//  MessageView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import DiscordKitCommon
import DiscordKit
import DiscordKitCore
import CachedAsyncImage

extension View {
    public func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

struct NewAttachmentError: Identifiable {
	var id: String { title + message }
	let title: String
	let message: String
}

struct HeaderChannelIcon: View {
	let iconName: String
	let background: Color
	let iconSize: CGFloat
	let size: CGFloat

	var body: some View {
		Image(systemName: iconName)
			.font(.system(size: iconSize))
			.foregroundColor(.white)
			.frame(width: size, height: size)
			.background(background)
			.clipShape(Circle())
	}
}

struct MessagesViewHeader: View {
	let chl: Channel?

	@EnvironmentObject var gateway: DiscordGateway

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			if chl?.type == .dm {
				if let rID = chl?.recipient_ids?[0],
				   let url = gateway.cache.users[rID]?.avatarURL(size: 160) {
					BetterImageView(url: url)
						.frame(width: 80, height: 80)
						.clipShape(Circle())
				}
			} else if chl?.type == .groupDM {
				HeaderChannelIcon(
					iconName: "person.2.fill",
					background: .red,
					iconSize: 30,
					size: 80
				)
			} else {
				HeaderChannelIcon(
					iconName: "number",
					background: .init(nsColor: .unemphasizedSelectedContentBackgroundColor),
					iconSize: 44,
					size: 68
				)
			}

			Text(chl?.type == .dm || chl?.type == .groupDM
				 ? "\(chl?.label(gateway.cache.users) ?? "")"
				 : "server.channel.title \(chl?.label() ?? "")")
				.font(.largeTitle)
				.fontWeight(.heavy)

			Text(
				chl?.type == .dm
				? "dm.header \(chl?.label(gateway.cache.users) ?? "")"
				: (chl?.type == .groupDM
				   ? "dm.group.header \(chl?.label(gateway.cache.users) ?? "")"
				   : "server.channel.header \(chl?.name ?? "") \(chl?.topic ?? "")"
				  )
			).opacity(0.7)
		}
		.padding([.top, .leading, .trailing], 16)
	}
}

struct DayDividerView: View {
	let date: Date

	var body: some View {
		HStack(spacing: 4) {
			HorizontalDividerView().frame(maxWidth: .infinity)
			Text(date, style: .date)
				.font(.system(size: 12))
				.fontWeight(.medium)
				.opacity(0.7)
			HorizontalDividerView().frame(maxWidth: .infinity)
		}
		.padding([.top, .horizontal], 16)
	}
}

struct MessagesView: View {
    @State internal var reachedTop = false
    @State internal var messages: [Message] = []
    @State internal var newMessage = " "
	@State internal var attachments: [URL] = []
    @State internal var showingInfoBar = false
    @State internal var loadError = false
    @State internal var infoBarData: InfoBarData?
    @State internal var fetchMessagesTask: Task<(), Error>?
    @State internal var lastSentTyping = Date(timeIntervalSince1970: 0)
	@State internal var newAttachmentErr: NewAttachmentError?
	@State private var messageInputHeight = 0.0
	@State private var dropOver = false
	@State private var highlightMsg: Snowflake?
	@State private var replyingID: Snowflake?

    @EnvironmentObject var gateway: DiscordGateway
	@EnvironmentObject var restAPI: DiscordREST
    @EnvironmentObject var state: UIState
    @EnvironmentObject var ctx: ServerContext

    // Gateway
    @State private var evtID: EventDispatch.HandlerIdentifier?

    var body: some View {
		ZStack(alignment: .bottom) {
            ScrollView(.vertical) {
                ScrollViewReader { proxy in
                    // This whole view is flipped, so everything in it needs to be flipped as well
                    LazyVStack(alignment: .leading, spacing: 0) {
                        Spacer(minLength: 16 + (showingInfoBar ? 24 : 0) + messageInputHeight)

                        ForEach(Array(messages.enumerated()), id: \.1.id) { (idx, msg) in
							VStack(spacing: 0) {
								if (idx == messages.count - 1 && reachedTop) ||
								   (idx != messages.count - 1 && !msg.timestamp.isSameDay(as: messages[idx+1].timestamp)) {
									DayDividerView(date: msg.timestamp)
								}

								MessageView(
									message: msg,
									shrunk: idx < messages.count - 1 && msg.messageIsShrunk(prev: messages[idx + 1]),
									quotedMsg: msg.message_reference != nil
									? messages.first {
										$0.id == msg.message_reference!.message_id
									} : nil,
									onQuoteClick: { id in
										withAnimation { proxy.scrollTo(id, anchor: .center) }
										highlightMsg = id
										DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
											if highlightMsg == id { highlightMsg = nil }
										}
									},
									onReply: {
										infoBarData = InfoBarData(
											message: "Replying to **\(msg.author.username)**",
											buttonLabel: "Cancel",
											color: .init(nsColor: .unemphasizedSelectedContentBackgroundColor),
											buttonIcon: "x.circle.fill",
											clickHandler: {
												replyingID = nil
												showingInfoBar = false
											}
										)
										showingInfoBar = true
										replyingID = msg.id
									},
									highlightMsgId: $highlightMsg
								)
							}.flip()
                        }

                        if reachedTop { MessagesViewHeader(chl: ctx.channel).flip() } else {
                            VStack(alignment: .leading, spacing: 16) {
                                // TODO: Use a loop to create this
								Group {
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
								}
								Group {
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
									LoFiMessageView()
								}
								// A ForEach with a range works initially
								// but doesn't show anything for subsequent loads
                            }
                            .onAppear {
								if fetchMessagesTask == nil { fetchMoreMessages() }
							}
                            .onDisappear {
                                if let loadTask = fetchMessagesTask {
                                    loadTask.cancel()
                                    fetchMessagesTask = nil
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .flip()
                        }
                    }
                }
            }
            .flip()
			.padding(.bottom, 31) // Typing bar + border radius = 24 + 7 = 31
            .frame(maxHeight: .infinity)

            ZStack(alignment: .topLeading) {
                MessageInfoBarView(isShown: $showingInfoBar, state: $infoBarData)

                MessageInputView(
					placeholder: ctx.channel?.type == .dm
					? "dm.composeMsg.hint \(ctx.channel?.label(gateway.cache.users) ?? "")"
					: (ctx.channel?.type == .groupDM
					   ? "dm.group.composeMsg.hint \(ctx.channel?.label(gateway.cache.users) ?? "")"
					   : "server.composeMsg.hint \(ctx.channel?.label(gateway.cache.users) ?? "")"
					  ),
					message: $newMessage, attachments: $attachments,
					onSend: sendMessage, preAttach: preAttachChecks
				)
                    .onAppear { newMessage = "" }
                    .onChange(of: newMessage) { [newMessage] content in
                        if content.count > newMessage.count,
                           Date().timeIntervalSince(lastSentTyping) > 8 {
                            // Send typing start msg once every 8s while typing
                            lastSentTyping = Date()
                            Task {
                                _ = await restAPI.typingStart(id: ctx.channel!.id)
                            }
                        }
                    }
					.overlay {
						let typingMembers = ctx.channel == nil
						? []
						: ctx.typingStarted[ctx.channel!.id]?
							.map { $0.member?.nick ?? $0.member?.user!.username ?? "" } ?? []

						if !typingMembers.isEmpty {
							HStack {
								// The dimensions are quite arbitrary
								LottieView(name: "typing-animation", play: .constant(true), width: 100, height: 80)
									.lottieLoopMode(.loop)
									.frame(width: 32, height: 24)
								Group {
									Text(typingMembers.count <= 2
										 ? typingMembers.joined(separator: " and ")
										 : "Several people"
									).fontWeight(.semibold)
									+ Text(" \(typingMembers.count == 1 ? "is" : "are") typing...")
								}.padding(.leading, -4)
							}
							.padding(.horizontal, 16)
							.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
						}
					}
					.background {
						GeometryReader { geomatry in
							ZStack {}
								.onAppear { messageInputHeight = geomatry.size.height }
								.onChange(of: geomatry.size.height) { messageInputHeight = $0 }
						}
					}
            }
        }
        .frame(minWidth: 525)
		.blur(radius: dropOver ? 24 : 0)
		.overlay {
			if dropOver {
				ZStack {
					VStack(spacing: 24) {
						Image(systemName: "paperclip")
							.font(.system(size: 64))
							.foregroundColor(.accentColor)
						Text("Drop file to add attachment").font(.largeTitle)
					}
					Rectangle()
						.stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, dash: [25, 20]))
						.opacity(0.75)
				}.padding(24)
			}
		}
		.animation(.easeOut(duration: 0.25), value: dropOver)
		.onDrop(of: [.fileURL], isTargeted: $dropOver) { providers -> Bool in
			for provider in providers {
				_ = provider.loadObject(ofClass: URL.self) { itemURL, err in
					if let itemURL = itemURL, preAttachChecks(for: itemURL) {
						attachments.append(itemURL)
					}
				}
			}
			return true
		}
        .onChange(of: ctx.channel, perform: { channel in
            guard let channel = channel else { return }
            messages = []
            // Prevent deadlocked and wrong message situations
			fetchMoreMessages()
            loadError = false
            reachedTop = false
            lastSentTyping = Date(timeIntervalSince1970: 0)

			AnalyticsWrapper.event(type: .channelOpened, properties: [
				"channel_id": channel.id,
				"channel_is_nsfw": String(channel.nsfw ?? false),
				"channel_type": String(channel.type.rawValue)
			])
        })
        .onChange(of: state.loadingState) { loadingState in
            if loadingState == .gatewayConn {
                guard fetchMessagesTask == nil else { return }
                messages = []
                fetchMoreMessages()
            }
        }
        .onDisappear {
            // Remove gateway event handler to prevent memory leaks
            guard let handlerID = evtID else { return}
            _ = gateway.onEvent.removeHandler(handler: handlerID)
        }
        .onAppear {
			fetchMoreMessages()

			// swiftlint:disable identifier_name
            evtID = gateway.onEvent.addHandler(handler: { (evt, d) in
                switch evt {
                case .messageCreate:
                    guard let msg = d as? Message else { break }
                    if msg.channel_id == ctx.channel?.id {
                        withAnimation { messages.insert(msg, at: 0) }
                    }
                    guard msg.webhook_id == nil else { break }
                    // Remove typing status when user sent a message
                    ctx.typingStarted[msg.channel_id]?.removeAll { $0.user_id == msg.author.id }
                case .messageUpdate:
                    guard let newMsg = d as? PartialMessage else { break }
					if let updatedIdx = messages.firstIndex(where: { $0.id == newMsg.id }) {
                        var updatedMsg = messages[updatedIdx]
                        updatedMsg.mergeWithPartialMsg(newMsg)
                        messages[updatedIdx] = updatedMsg
                    }
                case .messageDelete:
                    guard let deletedMsg = d as? MessageDelete else { break }
                    guard deletedMsg.channel_id == ctx.channel?.id else { break }
                    if let delIdx = messages.firstIndex(where: { $0.id == deletedMsg.id }) {
                        withAnimation { _ = messages.remove(at: delIdx) }
                    }
                case .messageDeleteBulk:
                    guard let deletedMsgs = d as? MessageDeleteBulk else { break }
                    guard deletedMsgs.channel_id == ctx.channel?.id else { break }
                    for msgID in deletedMsgs.id {
                        if let delIdx = messages.firstIndex(where: { $0.id == msgID }) {
                            withAnimation { _ = messages.remove(at: delIdx) }
                        }
                    }
                default: break
                }
            })
        }
		.alert(item: $newAttachmentErr) { err in
			Alert(
				title: Text(err.title),
				message: Text(err.message),
				dismissButton: .cancel(Text("Got It!"))
			)
		}
    }
}
