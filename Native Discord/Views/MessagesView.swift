//
//  MessageView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI

struct MessagesView: View {
    let channel: Channel
    @State private var messages: [Message] = []
    
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(messages.enumerated()), id: \.1.id) { (i, message) in
                        MessageView(
                            message: message,
                            shrunk: i != 0 && messages[i - 1].author.id == message.author.id && (messages[i - 1].type == .defaultMsg || messages[i - 1].type == .reply)
                        )
                    }
                }
            }
        }
        .navigationSubtitle(channel.name ?? "")
        .onAppear { Task {
            guard let m = await DiscordAPI.getChannelMsgs(id: channel.id) else {
                print("M is nil")
                return
            }
            print(m)
            messages = m.reversed()
        }}
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        // MessagesView()
        Text("TODO")
    }
}
