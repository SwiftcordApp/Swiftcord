//
//  MessageView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//
//  This monstrosity is a view that renders one message

import SwiftUI

struct MessageView: View {
    let guildID: Snowflake
    let message: Message
    let shrunk: Bool
    let lineSpacing = 4 as CGFloat
    let quotedMsg: Message?
    
    @State private var hovered = false
    @State private var loadedQuotedMsg: Message? = nil
    @State private var loadQuotedMsgErr = false
    @State private var playLoadAnim = false // Will turn true when first appeared
    
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
                        if (quotedMsg != nil || loadedQuotedMsg != nil) && !loadQuotedMsgErr {
                            AsyncImage(url: loadedQuotedMsg?.author.avatarURL() ?? quotedMsg!.author.avatarURL()) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                }
                                else if phase.error != nil {
                                    Image("DiscordIcon").frame(width: 12, height: 12)
                                } else {
                                     ProgressView()
                                        .progressViewStyle(.circular)
                                        .controlSize(.mini)
                                }
                            }
                            .clipShape(Circle())
                            .frame(width: 16, height: 16)
                            Text(loadedQuotedMsg?.author.username ?? quotedMsg!.author.username)
                                .font(.system(size: 14))
                                .opacity(0.9)
                            Text(loadedQuotedMsg?.content ?? quotedMsg!.content)
                                .font(.system(size: 14))
                                .opacity(0.75)
                                .lineLimit(1)
                        }
                        else if loadQuotedMsgErr {
                            Image(systemName: "xmark.octagon.fill")
                                .font(.system(size: 12))
                                .frame(width: 16, height: 16)
                            Text("Could not load quoted message")
                                .font(.system(size: 14))
                                .opacity(0.75)
                        }
                        else {
                             ProgressView()
                                .progressViewStyle(.circular)
                                .controlSize(.mini)
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
                    }.padding(.bottom, 4)
                    Spacer()
                }.padding(.leading, 20)
            }
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
                            HStack(alignment: .bottom, spacing: 8) {
                                Text(message.member?.nick ?? message.author.username)
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                Text("at \(message.timestamp.toDate()?.toTimeString() ?? "")")
                                    .font(.system(size: 12))
                                    .opacity(0.5)
                            }
                        }
                        // For including additional message components
                        VStack(alignment: .leading, spacing: 4) {
                            if !message.content.isEmpty {
                                Text(.init(message.content))
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
        }
        .padding(.leading, 16)
        .padding(.trailing, 48)
        .padding([.bottom, .top], lineSpacing / 2)
        .background(hovered ? .gray.opacity(0.07) : .clear)
        .padding(.top, shrunk ? 0 : 16 - lineSpacing / 2)
        .animation(.linear(duration: 0.1), value: hovered)
        .onHover { h in hovered = h }
        .animation(.interpolatingSpring(stiffness: 500, damping: 25), value: playLoadAnim)
        .onAppear(perform: {
            playLoadAnim = true
        })
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
