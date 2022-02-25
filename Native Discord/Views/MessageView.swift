//
//  MessageView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//
//  A view that renders one message

import SwiftUI

struct MessageView: View {
    let guildID: Snowflake
    let message: Message
    let shrunk: Bool
    let lineSpacing = 4 as CGFloat
    
    @State private var hovered = false
    
    var body: some View {
        HStack(
            alignment: message.type == .guildMemberJoin || message.type == .userPremiumGuildSub ? .center : .top,
            spacing: 16
        ) {
            // Would have loved to use switch-case but fallthrough doesn't work :(
            if message.type == .reply || message.type == .defaultMsg {
                if !shrunk {
                    UserAvatarView(user: message.author, guildID: guildID)
                }
                else {
                    Text(message.timestamp.toDate()?.toTimeString() ?? "")
                        .font(.custom("SF Compact Rounded", size: 10))
                        .frame(width: 40, height: 22, alignment: .center)
                        .animation(.linear(duration: 0.1), value: hovered)
                        .opacity(hovered ? 0.5 : 0)
                }
                VStack(alignment: .leading, spacing: lineSpacing) {
                    if !shrunk {
                        Text(message.member?.nick ?? message.author.username)
                            .font(.system(size: 15))
                            .fontWeight(.medium)
                    }
                    // For including additional message components
                    VStack(alignment: .leading, spacing: 4) {
                        if !message.content.isEmpty {
                            Text(message.content)
                                .font(.system(size: 15))
                                .textSelection(.enabled)
                        }
                        if message.sticker_items != nil {
                            ForEach(message.sticker_items!, id: \.id) { sticker in
                                StickerView(sticker: sticker)
                            }
                        }
                        ForEach(message.attachments, id: \.id) { attachment in
                            AttachmentView(attachment: attachment)
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
        .padding(.leading, 16)
        .padding(.trailing, 48)
        .padding([.bottom, .top], lineSpacing / 2)
        .background(hovered ? .gray.opacity(0.07) : .clear)
        .padding(.top, shrunk ? 0 : 16 - lineSpacing / 2)
        .animation(.linear(duration: 0.1), value: hovered)
        .onHover { h in hovered = h }
        .contextMenu {
            Button {
                
            } label: {
                // For some reason Label() with icon doesn't work...
                Image(systemName: "arrowshape.turn.up.left.fill")
                Text("Reply")
            }
            
            Group {
                Divider()
                Button {
                    
                } label: {
                    Image(systemName: "face.smiling.fill")
                    Text("Add Reaction")
                }
                Button {
                    
                } label: {
                    Image(systemName: "number")
                    Text("Create Thread")
                }
                Button {
                    
                } label: {
                    Image(systemName: "pin.fill")
                    Text("Pin Message")
                }
                
            }
            
            Divider()
            Button {
                
            } label: {
                Image(systemName: "pencil")
                Text("Edit")
            }
            Button {
                
            } label: {
                // role: .destructive does nothing
                Image(systemName: "xmark.bin.fill") // ...and .foregroundColor does nothing here
                Text("Delete Message").foregroundColor(.red)
            }
            
            Divider()
            Button {
                
            } label: {
                Image(systemName: "link")
                Text("Copy Link")
            }
            Button {
                
            } label: {
                Image(systemName: "number.circle.fill")
                Text("Copy ID")
            }
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        Text("TODO")
        // MessageView()
    }
}
