//
//  MessageView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import DiscordKit
import CachedAsyncImage

extension View {
    public func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
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
					CachedAsyncImage(url: url) { image in
						image.resizable().scaledToFill()
					} placeholder: { Rectangle().fill(.gray.opacity(0.2)) }
						.frame(width: 80, height: 80)
						.clipShape(Circle())
				}
			} else if chl?.type == .groupDM {
				Image(systemName: "person.2.fill")
					.font(.system(size: 30))
					.foregroundColor(.white)
					.frame(width: 80, height: 80)
					.background(.red)
					.clipShape(Circle())
			} else { Image(systemName: "number").font(.system(size: 60)) }

			Text(chl?.type == .dm || chl?.type == .groupDM
				 ? chl?.label(gateway.cache.users) ?? ""
				 : "Welcome to #\(chl?.label() ?? "")!")
				.font(.largeTitle)
				.fontWeight(.heavy)

			if chl?.type == .dm {
				Group {
					Text("This is the beginning of your direct message history with ")
						+ Text("@\(chl?.label(gateway.cache.users) ?? "")").fontWeight(.bold)
						+ Text(".")
				}.opacity(0.7)
			} else if chl?.type == .groupDM {
				Group {
					Text("Welcome to the beginning of the ")
						+ Text("\(chl?.label(gateway.cache.users) ?? "")").fontWeight(.bold)
						+ Text(" group.")
				}.opacity(0.7)
			} else {
				Text("This is the start of the #\(chl?.name ?? "") channel. \(chl?.topic ?? "")")
					.opacity(0.7)
			}
			Divider().padding(.top, 4)
		}
		.padding([.top, .leading, .trailing], 16)
	}
}

struct MessagesView: View, Equatable {
	static func == (lhs: MessagesView, rhs: MessagesView) -> Bool {
		lhs.messages == rhs.messages
	}

    @State private var reachedTop = false
    @State private var messages: [Message] = []
    @State private var enteredText = " "
    @State private var showingInfoBar = false
    @State private var loadError = false
    @State private var infoBarData: InfoBarData?
    @State private var fetchMessagesTask: Task<(), Error>?
    @State private var lastSentTyping = Date(timeIntervalSince1970: 0)
	@State private var messageInputHeight = 0.0

    @EnvironmentObject var gateway: DiscordGateway
    @EnvironmentObject var state: UIState
    @EnvironmentObject var ctx: ServerContext

    // Gateway
    @State private var evtID: EventDispatch.HandlerIdentifier?

    private func fetchMoreMessages() {
        guard let channel = ctx.channel else { return }
        if let oldTask = fetchMessagesTask {
            oldTask.cancel()
            fetchMessagesTask = nil
        }

        if loadError { showingInfoBar = false }
        loadError = false

        fetchMessagesTask = Task {
            let lastMsg = messages.isEmpty ? nil : messages[messages.count - 1].id

            guard let newMessages = await DiscordAPI.getChannelMsgs(
                id: channel.id,
                before: lastMsg
            ) else {
                try Task.checkCancellation() // Check if the task is cancelled before continuing

                fetchMessagesTask = nil
                loadError = true
                showingInfoBar = true
                infoBarData = InfoBarData(
                    message: "Messages failed to load",
                    buttonLabel: "Try again",
                    color: .red,
                    buttonIcon: "arrow.clockwise",
                    clickHandler: { fetchMoreMessages() }
                )
                state.loadingState = .messageLoad
                return
            }
            state.loadingState = .messageLoad
            try Task.checkCancellation()

            reachedTop = newMessages.count < 50
            messages.append(contentsOf: newMessages)
            fetchMessagesTask = nil
        }
    }

    private func sendMessage(content: String, attachments: [URL]) {
        lastSentTyping = Date(timeIntervalSince1970: 0)
        enteredText = ""
        showingInfoBar = false
        Task {
            guard (await DiscordAPI.createChannelMsg(
                message: NewMessage(
                    content: content,
                    attachments: attachments.isEmpty ? nil : attachments.enumerated()
						.map { (idx, attachment) in
							NewAttachment(
								id: String(idx),
								filename: try! attachment.resourceValues(forKeys: [URLResourceKey.nameKey]).name!
							)
						}
                ),
                attachments: attachments,
                id: ctx.channel!.id
            )) != nil else {
                enteredText = content.trimmingCharacters(in: .newlines) // Message failed to send
                showingInfoBar = true
                infoBarData = InfoBarData(
                    message: "Could not send message",
                    buttonLabel: "Try again",
                    color: .red,
                    buttonIcon: "arrow.clockwise",
                    clickHandler: { sendMessage(content: enteredText, attachments: attachments) }
                )
                return
            }
        }
    }

    var body: some View {
		ZStack(alignment: .bottom) {
            ScrollView(.vertical) {
                ScrollViewReader { proxy in
                    // This whole view is flipped, so everything in it needs to be flipped as well
                    LazyVStack(alignment: .leading, spacing: 0) {
                        Spacer(minLength: 16 + (showingInfoBar ? 24 : 0) + messageInputHeight)

                        ForEach(Array(messages.enumerated()), id: \.1.id) { (idx, msg) in
                            MessageView(
                                message: msg,
                                shrunk: idx < messages.count - 1 && msg.messageIsShrunk(prev: messages[idx + 1]),
                                quotedMsg: msg.message_reference != nil
                                ? messages.first {
                                    $0.id == msg.message_reference!.message_id
                                } : nil,
                                onQuoteClick: { id in
                                    withAnimation { proxy.scrollTo(id, anchor: .center) }
                                }
                            )
                            .flip()
                        }

                        if reachedTop { MessagesViewHeader(chl: ctx.channel).flip() } else {
                            VStack(alignment: .leading, spacing: 16) {
                                // TODO: Use a loop to create this
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
								// A ForEach with a range works initially
								// but doesn't show anything for subsequent loads
                            }
                            .onAppear { fetchMoreMessages() }
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
					placeholder: "Message \(ctx.channel?.type == .text ? "#" : "")\(ctx.channel?.label(gateway.cache.users) ?? "")",
					message: $enteredText, onSend: sendMessage
				)
                    .onAppear { enteredText = "" }
                    .onChange(of: enteredText) { [enteredText] content in
                        if content.count > enteredText.count,
                           Date().timeIntervalSince(lastSentTyping) > 8 {
                            // Send typing start msg once every 8s while typing
                            lastSentTyping = Date()
                            Task {
                                _ = await DiscordAPI.typingStart(id: ctx.channel!.id)
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
        .onChange(of: ctx.channel, perform: { channel in
            guard channel != nil else { return }
            messages = []
            // Prevent deadlocked and wrong message situations
            if loadError || fetchMessagesTask != nil { fetchMoreMessages() }
            loadError = false
            reachedTop = false
            lastSentTyping = Date(timeIntervalSince1970: 0)
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
    }
}
