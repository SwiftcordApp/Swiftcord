//
//  MessageView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI

extension View {
    public func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

struct MessagesView: View {
    @Binding var channel: Channel?
    let guildID: Snowflake
    @State private var reachedTop = false
    @State private var messages: [Message] = []
    @State private var enteredText = " "
    @State private var loading = false
    @State private var loadError = false
    @State private var scrollTopID: Snowflake? = nil
    
    @EnvironmentObject var gateway: DiscordGateway
    @EnvironmentObject var state: UIState
    
    // Gateway
    @State private var evtID: EventDispatch.HandlerIdentifier? = nil
    
    private func fetchMoreMessages() {
        guard let ch = channel else { return }
        loading = true
        loadError = false
        Task {
            let lastMsg = messages.isEmpty ? nil : messages[messages.count - 1].id
            if state.loadingState == .channelLoad { state.loadingState = .messageLoad }
            
            guard let m = await DiscordAPI.getChannelMsgs(
                id: ch.id,
                before: lastMsg
            ) else {
                loading = false
                loadError = true
                return
            }
            loading = false
            if !messages.isEmpty { scrollTopID = messages[messages.count - 1].id }
            reachedTop = m.count < 50
            messages.append(contentsOf: m)
        }
    }
    
    private func sendMessage(content: String) {
        let text = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        enteredText = ""
        Task {
            guard (await DiscordAPI.createChannelMsg(
                message: NewMessage(
                    content: content
                ),
                id: channel!.id
            )) != nil else {
                // TODO: Show some sort of indication that the message didn't send
                enteredText = content.trimmingCharacters(in: .newlines) // Message failed to send
                return
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !loadError {
                ScrollView(.vertical) {
                    ScrollViewReader { proxy in
                        // This whole view is flipped, so everything in it needs to be flipped as well
                        LazyVStack(alignment: .leading, spacing: 0) {
                            Spacer(minLength: 38)
                                .onChange(of: messages.count) { _ in
                                    guard messages.count >= 1 else { return }
                                    // This is _not_ bugged
                                    if scrollTopID != nil {
                                        proxy.scrollTo(scrollTopID!, anchor: .bottom)
                                        scrollTopID = nil
                                    }
                                }
                            
                            ForEach(Array(messages.enumerated()), id: \.1.id) { (i, msg) in
                                MessageView(
                                    guildID: guildID,
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
                                    Text("Welcome to #\(channel?.name ?? "")!")
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                    Text("This is the start of the #\(channel?.name ?? "") channel.")
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
                                .id("placeholder")
                                .onAppear {
                                    guard !loading else { return }
                                    fetchMoreMessages()
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .flip()
                            }
                        }
                    }
                }
                .flip()
                .frame(maxHeight: .infinity)
            }

            if loadError {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.red)
                    Text("Messages failed to load").font(.title2)
                    Button("Try Again") { fetchMoreMessages() }.controlSize(.large)
                }.frame(maxHeight: .infinity)
            }
            
            // RoundedRectangle(cornerRadius: 12).fill(.gray)
                //.frame(maxWidth: .infinity, maxHeight: 16)
            // TextField("Message #\(channel.name ?? "")", text: $enteredText)
            MessageInputView(placeholder: "Message #\(channel?.name ?? "")", message: $enteredText, onSend: sendMessage).onAppear { enteredText = "" }
            .onChange(of: enteredText) { content in
                guard !content.isEmpty && content.last!.isNewline else { return }
                sendMessage(content: content)
            }
        }
        .navigationTitle("#" + (channel?.name ?? ""))
        .frame(minWidth: 525)
        .onChange(of: channel, perform: { ch in
            guard ch != nil else { return }
            messages = []
            loading = false
            loadError = false
            reachedTop = false
            scrollTopID = nil
        })
        .onDisappear {
            // Remove gateway event handler to prevent memory leaks
            guard let handlerID = evtID else { return}
            let _ = gateway.onEvent.removeHandler(handler: handlerID)
        }
        .onAppear {
            evtID = gateway.onEvent.addHandler(handler: { (evt, d) in
                switch evt {
                case .messageCreate:
                    guard let msg = d as? Message else { break }
                    if msg.channel_id == channel?.id {
                        withAnimation {
                            messages.insert(msg, at: 0)
                        }
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
                    guard deletedMsg.channel_id == channel?.id else { break }
                    if let delIdx = messages.firstIndex(where: { m in m.id == deletedMsg.id }) {
                        withAnimation { let _ = messages.remove(at: delIdx) }
                    }
                case .messageDeleteBulk:
                    guard let deletedMsgs = d as? MessageDeleteBulk else { break }
                    guard deletedMsgs.channel_id == channel?.id else { break }
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
