//
//  MessageView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import DiscordKit

extension View {
    public func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

struct MessagesView: View {
    @State private var reachedTop = false
    @State private var messages: [Message] = []
    @State private var enteredText = " "
    @State private var scrollTopID: Snowflake? = nil
    @State private var showingInfoBar = false
    @State private var loadError = false
    @State private var infoBarData: InfoBarData? = nil
    @State private var fetchMessagesTask: Task<(), Error>? = nil
    @State private var lastSentTyping = Date(timeIntervalSince1970: 0)
	@State private var messageInputHeight = 0.0
    
    @EnvironmentObject var gateway: DiscordGateway
    @EnvironmentObject var state: UIState
    @EnvironmentObject var serverCtx: ServerContext
    
    // Gateway
    @State private var evtID: EventDispatch.HandlerIdentifier? = nil
        
    private func fetchMoreMessages() {
		print("load masssages")
        guard let ch = serverCtx.channel else { return }
        if let oldTask = fetchMessagesTask {
            oldTask.cancel()
            fetchMessagesTask = nil
        }
        
        if loadError { showingInfoBar = false }
        loadError = false
        
        fetchMessagesTask = Task {
            let lastMsg = messages.isEmpty ? nil : messages[messages.count - 1].id
            
            guard let m = await DiscordAPI.getChannelMsgs(
                id: ch.id,
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
            
            if !messages.isEmpty { scrollTopID = messages[messages.count - 1].id }
            reachedTop = m.count < 50
            messages.append(contentsOf: m)
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
                    attachments: attachments.isEmpty ? nil : attachments.enumerated().map { (i, a) in
                        NewAttachment(
                            id: String(i),
                            filename: try! a.resourceValues(forKeys: [URLResourceKey.nameKey]).name!
                        )
                    }
                ),
                attachments: attachments,
                id: serverCtx.channel!.id
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
                            .onChange(of: messages.count) { _ in
                                guard messages.count >= 1 else { return }
                                // This is _not_ bugged
                                if let scrollTopID = scrollTopID {
                                    proxy.scrollTo(scrollTopID, anchor: .bottom)
									self.scrollTopID = nil
                                }
                            }
                        
                        ForEach(Array(messages.enumerated()), id: \.1.id) { (i, msg) in
                            MessageView(
                                message: msg,
                                shrunk: i < messages.count - 1 && msg.messageIsShrunk(prev: messages[i + 1]),
                                quotedMsg: msg.message_reference != nil
                                ? messages.first { m in
                                    m.id == msg.message_reference!.message_id
                                } : nil,
                                onQuoteClick: { id in
                                    withAnimation { proxy.scrollTo(id, anchor: .center) }
                                }
                            )
                            .flip()
                        }
                        
                        if reachedTop {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: "number")
                                    .font(.system(size: 60))
                                Text("Welcome to #\(serverCtx.channel?.name ?? "")!")
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                Text("This is the start of the #\(serverCtx.channel?.name ?? "") channel.")
                                    .opacity(0.7)
                                Divider()
                                    .padding(.top, 4)
                            }
                            .padding([.top, .leading, .trailing], 16)
                            .flip()
                        }
                        else {
                            VStack(alignment: .leading, spacing: 16) {
                                // TODO: Use a loop to create this
                                LoFiMessageView()
                                LoFiMessageView()
                                LoFiMessageView()
                                LoFiMessageView()
                                LoFiMessageView()
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
                
                MessageInputView(placeholder: "Message #\(serverCtx.channel?.name ?? "")", message: $enteredText, onSend: sendMessage)
                    .onAppear { enteredText = "" }
                    .onChange(of: enteredText) { [enteredText] content in
                        if content.count > enteredText.count,
                           Date().timeIntervalSince(lastSentTyping) > 8 {
                            // Send typing start msg once every 8s while typing
                            lastSentTyping = Date()
                            Task {
                                let _ = await DiscordAPI.typingStart(id: serverCtx.channel!.id)
                            }
                        }
                    }
					.overlay {
						let typingMembers = serverCtx.channel == nil
						? []
						: serverCtx.typingStarted[serverCtx.channel!.id]?
							.map { t in t.member?.nick ?? t.member?.user!.username ?? "" } ?? []
						
						if !typingMembers.isEmpty {
							HStack() {
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
						GeometryReader { g in
							ZStack {}
								.onAppear { messageInputHeight = g.size.height }
								.onChange(of: g.size.height) { h in messageInputHeight = h }
						}
					}
            }
        }
        .frame(minWidth: 525)
        .onChange(of: serverCtx.channel, perform: { ch in
            guard ch != nil else { return }
            messages = []
            // Prevent deadlocked and wrong message situations
            if loadError || fetchMessagesTask != nil { fetchMoreMessages() }
            loadError = false
            reachedTop = false
            scrollTopID = nil
            lastSentTyping = Date(timeIntervalSince1970: 0)
        })
        .onChange(of: state.loadingState) { ns in
            if ns == .gatewayConn {
                guard fetchMessagesTask == nil else { return }
                messages = []
                fetchMoreMessages()
            }
        }
        .onDisappear {
            // Remove gateway event handler to prevent memory leaks
            guard let handlerID = evtID else { return}
            let _ = gateway.onEvent.removeHandler(handler: handlerID)
        }
        .onAppear {
			print("appear")
			fetchMoreMessages()
			
            evtID = gateway.onEvent.addHandler(handler: { (evt, d) in
                switch evt {
                case .messageCreate:
                    guard let msg = d as? Message else { break }
                    if msg.channel_id == serverCtx.channel?.id {
                        withAnimation { messages.insert(msg, at: 0) }
                    }
                    guard msg.webhook_id == nil else { break }
                    // Remove typing status when user sent a message
                    serverCtx.typingStarted[msg.channel_id]?.removeAll { t in
                        t.user_id == msg.author.id
                    }
                case .messageUpdate:
                    guard let newMsg = d as? PartialMessage else { break }
                    if let updatedIdx = messages.firstIndex(where: { m in m.id == newMsg.id }) {
                        var updatedMsg = messages[updatedIdx]
                        updatedMsg.mergeWithPartialMsg(newMsg)
                        messages[updatedIdx] = updatedMsg
                    }
                case .messageDelete:
                    guard let deletedMsg = d as? MessageDelete else { break }
                    guard deletedMsg.channel_id == serverCtx.channel?.id else { break }
                    if let delIdx = messages.firstIndex(where: { m in m.id == deletedMsg.id }) {
                        withAnimation { let _ = messages.remove(at: delIdx) }
                    }
                case .messageDeleteBulk:
                    guard let deletedMsgs = d as? MessageDeleteBulk else { break }
                    guard deletedMsgs.channel_id == serverCtx.channel?.id else { break }
                    for msgID in deletedMsgs.id {
                        if let delIdx = messages.firstIndex(where: { m in m.id == msgID }) {
                            withAnimation { let _ = messages.remove(at: delIdx) }
                        }
                    }
                default: break
                }
            })
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        // MessagesView()
        Text("TODO")
    }
}
