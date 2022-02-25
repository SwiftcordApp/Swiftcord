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
    let channel: Channel
    let guildID: Snowflake
    @State private var reachedTop = false
    @State private var messages: [Message] = []
    @State private var enteredText = " "
    @State private var loading = false
    @State private var scrollTopID: Snowflake? = nil
    
    @EnvironmentObject var gateway: DiscordGateway
    
    private func fetchMoreMessages() {
        loading = true
        Task {
            let lastMsg = messages.isEmpty ? nil : messages[messages.count - 1].id
            guard let m = await DiscordAPI.getChannelMsgs(
                id: channel.id,
                before: lastMsg
            ) else {
                loading = false
                return
            }
            loading = false
            if !messages.isEmpty { scrollTopID = messages[messages.count - 1].id }
            reachedTop = m.count < 50
            messages.append(contentsOf: m)
        }
    }
    
    private func sendMessage(content: String) {
        enteredText = ""
        Task {
            guard let m = await DiscordAPI.createChannelMsg(
                message: NewMessage(
                    content: content
                ),
                id: channel.id
            ) else {
                // TODO: Show some sort of indication that the message didn't send
                enteredText = content // Message failed to send
                return
            }
            print(m)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                ScrollViewReader { proxy in
                    // This whole view is flipped, so everything in it needs to be flipped as well
                    LazyVStack(alignment: .leading, spacing: 0) {
                        Spacer(minLength: 38)
                        
                        ForEach(Array(messages.enumerated()), id: \.1.id) { (i, msg) in
                            MessageView(
                                guildID: guildID,
                                message: msg,
                                shrunk: i < messages.count - 1 && msg.messageIsShrunk(prev: messages[i + 1]),
                                quotedMsg: msg.message_reference != nil
                                ? messages.first { m in
                                    m.id == msg.message_reference!.message_id
                                } : nil
                            )
                            .flip()
                        }
                        .onChange(of: messages.count) { _ in
                            guard messages.count >= 1 else { return }
                            // This is _not_ bugged
                            if scrollTopID != nil {
                                proxy.scrollTo(scrollTopID!, anchor: .bottom)
                                scrollTopID = nil
                            }
                        }
                        
                        if reachedTop {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: "number")
                                    .font(.system(size: 60))
                                Text("Welcome to #\(channel.name ?? "")!")
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                Text("This is the start of the #\(channel.name ?? "") channel.")
                                    .opacity(0.7)
                                Divider()
                                    .padding(.top, 4)
                            }
                            .padding([.top, .leading, .trailing], 16)
                            .flip()
                        }
                        else {
                            VStack(alignment: .center, spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .controlSize(.small)
                                Text("Loading messages...")
                            }
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
            .navigationTitle("#" + (channel.name ?? ""))
            .frame(maxHeight: .infinity)
            
            // RoundedRectangle(cornerRadius: 12).fill(.gray)
                //.frame(maxWidth: .infinity, maxHeight: 16)
            // TextField("Message #\(channel.name ?? "")", text: $enteredText)
            MessageInputView(placeholder: "Message #\(channel.name ?? "")", message: $enteredText, onSend: sendMessage).onAppear { enteredText = "" }
            .onChange(of: enteredText) { content in
                guard !content.isEmpty && content.last!.isNewline else { return }
                sendMessage(content: content)
            }
        }
        .frame(minWidth: 525)
        .onAppear {
            let _ = gateway.onEvent.addHandler(handler: { (evt, d) in
                switch evt {
                case .messageCreate:
                    guard let msg = d as? Message else { break }
                    if msg.channel_id == channel.id { messages.insert(msg, at: 0) }
                default: print("Handling event \(evt) not implemented")
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
