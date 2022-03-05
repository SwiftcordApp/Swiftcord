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
    let onQuoteClick: (String) -> Void
    
    @State private var hovered = false
    @State private var loadedQuotedMsg: Message? = nil
    @State private var loadQuotedMsgErr = false
    @State private var playLoadAnim = false // Will turn true when first appeared
    
    private func attributedMessage(content: String) -> AttributedString? {
        guard var str = try? AttributedString(markdown: message.content) else { return nil }
        
        // This is not really gonna work
        if let range = str.range(of: "<@[^>]*>", options: .regularExpression) {
            var mention = AttributedString("@a random user")
            mention.backgroundColor = Color("DiscordTheme").opacity(0.3)
            str.replaceSubrange(range, with: mention)
            // str[mention].backgroundColor = Color.indigo
        }
        return str
    }
    
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
                            Group {
                                Text(loadedQuotedMsg?.author.username ?? quotedMsg!.author.username)
                                    .font(.system(size: 14))
                                    .opacity(0.9)
                                Text(loadedQuotedMsg?.content ?? quotedMsg!.content)
                                    .font(.system(size: 14))
                                    .opacity(0.75)
                                    .lineLimit(1)
                            }.onTapGesture { onQuoteClick((loadedQuotedMsg ?? quotedMsg!).id) }
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
                    }
                    .padding(.bottom, 4)
                    Spacer()
                }.padding(.leading, 20)
            }
            HStack(
                alignment: message.type == .guildMemberJoin || message.type == .userPremiumGuildSub ? .center : .top,
                spacing: 16
            ) {
                // Would have loved to use switch-case but fallthrough doesn't work :(
                let timestring = message.timestamp.toDate()?.toTimeString() ?? ""
                if message.type == .reply || message.type == .defaultMsg {
                    if !shrunk {
                        UserAvatarView(user: message.author, guildID: guildID, webhookID: message.webhook_id)
                    }
                    else {
                        Text(timestring)
                            .font(.custom("SF Compact Rounded", size: 10))
                            .frame(width: 40, height: 22, alignment: .center)
                            .animation(.linear(duration: 0.1), value: hovered)
                            .opacity(hovered ? 0.5 : 0)
                    }
                    VStack(alignment: .leading, spacing: lineSpacing) {
                        if !shrunk {
                            HStack(alignment: .bottom, spacing: 6) {
                                Text(message.member?.nick ?? message.author.username)
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                if message.author.bot ?? false {
                                    HStack(spacing: 0) {
                                        if ((message.author.public_flags ?? 0) & (1 << 16)) != 0 || message.webhook_id != nil {
                                            Image(systemName: message.webhook_id == nil ? "checkmark" : "link")
                                                .font(.system(size: 8, weight: .heavy))
                                                .frame(width: 15)
                                                .padding(.leading, -3)
                                        }
                                        Text(message.webhook_id == nil
                                            ? "BOT"
                                            : "WEBHOOK"
                                        ).font(.system(size: 10))
                                    }
                                    .frame(height: 15)
                                    .padding(.horizontal, 4)
                                    .background(Color("DiscordTheme"))
                                    .cornerRadius(4)
                                    .offset(y: -2)
                                }
                                Text(timestring + (message.edited_timestamp != nil ? " • Edited: \(message.edited_timestamp!.toDate()?.toTimeString() ?? "")" : ""))
                                    .font(.system(size: 12))
                                    .opacity(0.5)
                            }
                        }
                        // For including additional message components
                        VStack(alignment: .leading, spacing: 4) {
                            if !message.content.isEmpty {
                                // Guard doesn't work in a view :(((
                                /*if let msg = attributedMessage(content: message.content) {
                                    Text(msg)
                                        .font(.system(size: 15))
                                        .textSelection(.enabled)
                                 // fix this poor implementation later
                                }*/
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
                            ForEach(message.embeds, id: \.id) { embed in
                                EmbedView(embed: embed)
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
