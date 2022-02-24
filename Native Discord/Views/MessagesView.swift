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
    @State private var reachedTop = false
    @State private var messages: [Message] = []
    @State private var enteredText = ""
    @State private var loading = false
    @State private var scrollTopID: Snowflake? = nil
    
    private func fetchMoreMessages() {
        loading = true
        Task {
            guard let m = await DiscordAPI.getChannelMsgs(
                id: channel.id,
                before: messages.isEmpty ? nil : messages[messages.count - 1].id
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
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ScrollViewReader { proxy in
                    // This whole view is flipped, so everything in it needs to be flipped as well
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(messages.enumerated()), id: \.1.id) { (i, message) in
                            MessageView(
                                guildID: channel.guild_id,
                                message: message,
                                shrunk: i < messages.count - 1 && messages[i + 1].author.id == message.author.id && (messages[i + 1].type == .defaultMsg || messages[i + 1].type == .reply)
                            )
                            .flip()
                        }
                        .onChange(of: messages.count) { _ in
                            guard messages.count >= 1 else { return }
                            // This is bugged
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
            TextField("Message #\(channel.name ?? "")", text: $enteredText)
        }
        .frame(minWidth: 520)
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        // MessagesView()
        Text("TODO")
    }
}
