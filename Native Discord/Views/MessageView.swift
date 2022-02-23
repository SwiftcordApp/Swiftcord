//
//  MessageView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//
//  A view that renders one message

import SwiftUI

struct MessageView: View {
    let message: Message
    let shrunk: Bool
    let lineSpacing = 3 as CGFloat
    
    @State private var hovered = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Would have loved to use switch-case but fallthrough doesn't work :(
            if message.type == .reply || message.type == .defaultMsg {
                if !shrunk { UserAvatarView(user: message.author) }
                else { ZStack { EmptyView() }.frame(width: 40) }
                VStack(alignment: .leading, spacing: lineSpacing) {
                    if !shrunk {
                        Text(message.member?.nick ?? message.author.username)
                            .font(.system(size: 15))
                            .fontWeight(.medium)
                    }
                    // For including additional message components
                    VStack {
                        if !message.content.isEmpty {
                            Text(message.content)
                                .font(.system(size: 15))
                        }
                        if message.sticker_items != nil {
                            ForEach(message.sticker_items!, id: \.id) { sticker in
                                StickerView(sticker: sticker)
                            }
                        }
                    }
                    .padding(.bottom, 1) // Pixel perfection ✨
                }
            }
            else if message.type == .guildMemberJoin {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 16))
                    .padding([.leading, .trailing], 12)
                Text("Welcome, \(message.author.username), enjoy your stay!")
                    .font(.system(size: 14)).opacity(0.5).padding(.top, 1)
            }
            Spacer()
        }
        .padding(.leading, 16)
        .padding(.trailing, 48)
        .padding(.top, shrunk ? 0 : 16)
        .padding(.bottom, shrunk ? lineSpacing : 0)
        .onHover { h in hovered = h }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        Text("TODO")
        // MessageView()
    }
}
