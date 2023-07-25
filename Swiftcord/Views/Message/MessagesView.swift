//
//  MessagesView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import DiscordKit
import DiscordKitCore
import CachedAsyncImage
import Introspect
import Combine

extension View {
    public func flip() -> some View {
        self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

struct NewAttachmentError: Identifiable {
    var id: String { title + message }
    let title: String
    let message: String
}

struct HeaderChannelIcon: View {
    let iconName: String
    let background: Color
    let iconSize: CGFloat
    let size: CGFloat

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: iconSize))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(background)
            .clipShape(Circle())
    }
}

struct MessagesViewHeader: View {
    let chl: Channel?

    @EnvironmentObject var gateway: DiscordGateway

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if chl?.type == .dm {
                if let rID = chl?.recipient_ids?[0],
                   let url = gateway.cache.users[rID]?.avatarURL(size: 160) { // swiftlint:disable:this indentation_width
                    BetterImageView(url: url)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                }
            } else if chl?.type == .groupDM {
                HeaderChannelIcon(
                    iconName: "person.2.fill",
                    background: .red,
                    iconSize: 30,
                    size: 80
                )
            } else {
                HeaderChannelIcon(
                    iconName: "number",
                    background: .init(nsColor: .unemphasizedSelectedContentBackgroundColor),
                    iconSize: 44,
                    size: 68
                )
            }

            Text(
                chl?.type == .dm || chl?.type == .groupDM
                ? "\(chl?.label(gateway.cache.users) ?? "")"
                : "server.channel.title \(chl?.label() ?? "")"
            )
            .font(.largeTitle)
            .fontWeight(.heavy)

            Text(
                chl?.type == .dm
                ? "dm.header \(chl?.label(gateway.cache.users) ?? "")"
                : chl?.type == .groupDM
                ? "dm.group.header \(chl?.label(gateway.cache.users) ?? "")"
                : "server.channel.header \(chl?.name ?? "") \(chl?.topic ?? "")"
            ).opacity(0.7)
        }
        .padding(.top, 16)
    }
}

struct DayDividerView: View {
    let date: Date

    var body: some View {
        HStack(spacing: 4) {
            HorizontalDividerView().frame(maxWidth: .infinity)
            Text(date, style: .date)
                .font(.system(size: 12))
                .fontWeight(.medium)
                .opacity(0.7)
            HorizontalDividerView().frame(maxWidth: .infinity)
        }
        .padding(.top, 16)
    }
}

struct UnreadDivider: View {
    var body: some View {
        HStack(spacing: 0) {
            HorizontalDividerView(color: .red).frame(maxWidth: .infinity)
            Text("New")
                .textCase(.uppercase).font(.headline)
                .padding(.horizontal, 4).padding(.vertical, 2)
                .background(RoundedRectangle(cornerRadius: 4).fill(.red))
                .foregroundColor(.white)
        }.padding(.vertical, 4)
    }
}

struct UnreadDayDividerView: View {
    let date: Date
    
    var body: some View {
        
        HStack(spacing: 0) {
            HStack(spacing: 4) {
                HorizontalDividerView(color: .red).frame(maxWidth: .infinity)
                Text(date, style: .date)
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                    .opacity(0.7)
                HorizontalDividerView(color: .red).frame(maxWidth: .infinity)
            }
            .foregroundColor(.red)
            Text("New")
                .textCase(.uppercase).font(.headline)
                .padding(.horizontal, 4).padding(.vertical, 2)
                .background(RoundedRectangle(cornerRadius: 4).fill(.red))
                .foregroundColor(.white)
        }
        .padding(.top, 16)
    }
}

struct MessagesView: View {
    @EnvironmentObject var gateway: DiscordGateway
    @EnvironmentObject var state: UIState
    @EnvironmentObject var ctx: ServerContext

    @StateObject var viewModel = MessagesViewModel()

    @State private var messageInputHeight: CGFloat = 0

    // Gateway
    @State private var evtID: EventDispatch.HandlerIdentifier?
    // @State private var scrollSinkCancellable: AnyCancellable?

    // static let scrollPublisher = PassthroughSubject<Snowflake, Never>()

    private var loadingSkeleton: some View {
        VStack(spacing: 0) {
            ForEach(0..<10) { _ in
                LoFiMessageView().padding(.vertical, 8)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @_transparent @_optimize(speed) @ViewBuilder
    func cell(for msg: Message, shrunk: Bool, proxy: ScrollViewProxy) -> some View {
        MessageView(
            message: msg,
            shrunk: shrunk,
            quotedMsg: msg.message_reference != nil
            ? viewModel.messages.first {
                $0.id == msg.message_reference!.message_id
            } : nil,
            onQuoteClick: { id in
                withAnimation { proxy.scrollTo(id, anchor: .center) }
                viewModel.highlightMsg = id
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if viewModel.highlightMsg == id { viewModel.highlightMsg = nil }
                }
            },
            replying: $viewModel.replying,
            highlightMsgId: $viewModel.highlightMsg
        )
        .equatable()
        .listRowBackground(msg.mentions(gateway.cache.user?.id) ? Color.orange.opacity(0.1) : .clear)
    }

    func history(proxy: ScrollViewProxy) -> some View {
        let reversed = viewModel.messages.reversed()
        return ForEach(Array(reversed.enumerated()), id: \.1.id) { (idx, msg) in
            let isLastItem = idx == 0
            let shrunk = !isLastItem && msg.messageIsShrunk(prev: reversed.before(msg)!)
            
            let newDay = isLastItem && viewModel.reachedTop || !isLastItem && !msg.timestamp.isSameDay(as: reversed.before(msg)!.timestamp)
            
            var newMsg: Bool {
                if !isLastItem, let channelID = ctx.channel?.id {
                    return gateway.readState[channelID]?.last_message_id?.stringValue == reversed.before(msg)!.id
                }
                return false
            }
            
            if newDay && newMsg {
                UnreadDayDividerView(date: msg.timestamp)
            } else if newDay {
                DayDividerView(date: msg.timestamp)
            }
            
            if !shrunk && !newMsg {
                Spacer(minLength: 16 - MessageView.lineSpacing / 2)
            }
            if !newDay && newMsg {
                UnreadDivider()
                    .id("unread")
            }
            
            cell(for: msg, shrunk: shrunk, proxy: proxy)
                .id(msg.id)
        }
        .zeroRowInsets()
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var historyList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Group {
//                    Spacer(minLength: 52).zeroRowInsets() // Ensure content is fully visible and not hidden behind toolbar when scrolled to the top
                    
                    if viewModel.reachedTop {
                        MessagesViewHeader(chl: ctx.channel).zeroRowInsets()
                    } else {
                        loadingSkeleton
                            .zeroRowInsets()
                            .onAppear { if viewModel.fetchMessagesTask == nil { fetchMoreMessages() } }
                            .onDisappear {
                                if let loadTask = viewModel.fetchMessagesTask {
                                    loadTask.cancel()
                                    viewModel.fetchMessagesTask = nil
                                }
                            }
                    }
                    
                    history(proxy: proxy)
                        .onAppear {
                            withAnimation {
                                // Scroll to very bottom if read, otherwise scroll to message
                                if gateway.readState[ctx.channel?.id ?? "1"]?.last_message_id?.stringValue ?? "1" == viewModel.messages.first?.id ?? "1" {
                                    proxy.scrollTo("1", anchor: .bottom)
                                } else {
                                    proxy.scrollTo("unread", anchor: .bottom)
                                }
                            }
                        }
                    
                    Spacer(minLength: max(messageInputHeight-74-7, 5) + (viewModel.showingInfoBar ? 24 : 0)).zeroRowInsets()
                        .id("1")
                }
                .padding(.horizontal, 15)
            }
            .introspectScrollView { scrollView in
                scrollView.drawsBackground = false
                scrollView.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
            .environment(\.defaultMinListRowHeight, 1) // By SwiftUI's logic, 0 is negative so we use 1 instead
            .background(.clear)
            .frame(maxHeight: .infinity)
            .padding(.bottom, 74 + 7) // Ensure List doesn't go below text input field (and its border radius)
        }
    }

    private var inputContainer: some View {
        ZStack(alignment: .topLeading) {
            MessageInfoBarView(isShown: $viewModel.showingInfoBar, state: $viewModel.infoBarData)

            MessageInputView(
                placeholder: ctx.channel?.type == .dm
                ? "dm.composeMsg.hint \(ctx.channel?.label(gateway.cache.users) ?? "")"
                : (ctx.channel?.type == .groupDM
                    ? "dm.group.composeMsg.hint \(ctx.channel?.label(gateway.cache.users) ?? "")"
                    : "server.composeMsg.hint \(ctx.channel?.label(gateway.cache.users) ?? "")"
                ),
                message: $viewModel.newMessage, attachments: $viewModel.attachments, replying: $viewModel.replying,
                onSend: sendMessage,
                preAttach: preAttachChecks
            )
            .onAppear { viewModel.newMessage = "" }
            .onChange(of: viewModel.newMessage) { content in
                if content.count > viewModel.newMessage.count,
                   Date().timeIntervalSince(viewModel.lastSentTyping) > 8 { // swiftlint:disable:this indentation_width
                    // Send typing start msg once every 8s while typing
                    viewModel.lastSentTyping = Date()
                    Task {
                        _ = try? await restAPI.typingStart(id: ctx.channel!.id)
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
                        // FIXME: The animation broke, will have to fix it
                        LottieView(name: "typing-animatiokn", play: .constant(true), width: 160, height: 160)
                            .lottieLoopMode(.loop)
                            .frame(width: 32, height: 24)
                        Group {
                            Text(
                                typingMembers.count <= 2
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
            .heightReader($messageInputHeight)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            historyList
            inputContainer
        }
        .frame(minWidth: 525, minHeight: 500)
        // .blur(radius: viewModel.dropOver ? 8 : 0)
        .overlay {
            if viewModel.dropOver {
                ZStack {
                    VStack(spacing: 24) {
                        Image(systemName: "paperclip")
                            .font(.system(size: 64))
                            .foregroundColor(.accentColor)
                        Text("Drop file to add attachment").font(.largeTitle)
                    }
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, dash: [25, 20]))
                        .opacity(0.75)
                }
                .padding(24)
                .background(.thickMaterial)
            }
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.dropOver)
        .onDrop(of: [.fileURL], isTargeted: $viewModel.dropOver) { providers -> Bool in
            print("Drop: \(providers)")
            for provider in providers {
                _ = provider.loadObject(ofClass: URL.self) { itemURL, err in
                    if let itemURL = itemURL, preAttachChecks(for: itemURL) {
                        viewModel.attachments.append(itemURL)
                    }
                }
            }
            return true
        }
        .onChange(of: ctx.channel) { channel in
            guard let channel = channel else { return }
            viewModel.messages = []
            // Prevent deadlocked and wrong message situations
            fetchMoreMessages()
            viewModel.loadError = false
            viewModel.reachedTop = false
            viewModel.lastSentTyping = Date(timeIntervalSince1970: 0)

            AnalyticsWrapper.event(type: .channelOpened, properties: [
                "channel_id": channel.id,
                "channel_is_nsfw": String(channel.nsfw ?? false),
                "channel_type": String(channel.type.rawValue)
            ])
        }
        .onChange(of: state.loadingState) { loadingState in
            if loadingState == .gatewayConn {
                guard viewModel.fetchMessagesTask == nil else { return }
                viewModel.messages = []
                fetchMoreMessages()
            }
        }
        .onDisappear {
            // Remove gateway event handler to prevent memory leaks
            guard let handlerID = evtID else { return }
            _ = gateway.onEvent.removeHandler(handler: handlerID)
        }
        .onAppear {
            fetchMoreMessages()

            evtID = gateway.onEvent.addHandler { evt in
                switch evt {
                case .messageCreate(let msg):
                    if msg.channel_id == ctx.channel?.id {
                        viewModel.addMessage(msg)
                    }
                    guard msg.webhook_id == nil else { break }
                    // Remove typing status after user sent a message
                    ctx.typingStarted[msg.channel_id]?.removeAll { $0.user_id == msg.author.id }
                case .messageUpdate(let newMsg):
                    guard newMsg.channel_id == ctx.channel?.id else { break }
                    viewModel.updateMessage(newMsg)
                case .messageDelete(let delMsg):
                    guard delMsg.channel_id == ctx.channel?.id else { break }
                    viewModel.deleteMessage(delMsg)
                case .messageDeleteBulk(let delMsgs):
                    guard delMsgs.channel_id == ctx.channel?.id else { break }
                    viewModel.deleteMessageBulk(delMsgs)
                default: break
                }
            }
        }
        .alert(item: $viewModel.newAttachmentErr) { err in
            Alert(
                title: Text(err.title),
                message: Text(err.message),
                dismissButton: .cancel(Text("Got It!"))
            )
        }
    }
}
