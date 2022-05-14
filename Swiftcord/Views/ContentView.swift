//
//  ContentView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import SwiftUI
import CoreData
import os

struct CustomHorizontalDivider: View {
    var body: some View {
        Rectangle().fill(Color(NSColor.separatorColor))
    }
}


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    /*@FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MessageItem.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<MessageItem>*/
    
    @State private var sheetOpen = false
    @State private var selectedGuild: Guild? = nil
    @State private var loadingGuildID: Snowflake? = nil
    
    @StateObject var loginWVModel: WebViewModel = WebViewModel(link: "https://canary.discord.com/login")
    @StateObject private var audioManager = AudioCenterManager()
    
    @EnvironmentObject var gateway: DiscordGateway
    @EnvironmentObject var state: UIState
    
    private let log = Logger(category: "ContentView")
    
    private func makeDMGuild() -> Guild {
        return Guild(id: "@me", name: "DMs", owner_id: "", afk_timeout: 0, verification_level: .none, default_message_notifications: .all, explicit_content_filter: .disabled, roles: [], emojis: [], features: [], mfa_level: .none, system_channel_flags: 0, channels: gateway.cache.dms, premium_tier: .none, preferred_locale: .englishUS, nsfw_level: .default, premium_progress_bar_enabled: false)
    }

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ServerButton(
                        selected: selectedGuild?.isDMChannel ?? false,
                        name: "Home",
                        assetIconName: "DiscordIcon",
                        onSelect: { selectedGuild = makeDMGuild() }
                    ).padding(.top, 4)
                    
                    CustomHorizontalDivider().frame(width: 32, height: 1)
                    
                    ForEach(gateway.cache.guilds ?? []) { guild in
                        ServerButton(
                            selected: selectedGuild?.id == guild.id || loadingGuildID == guild.id,
                            name: guild.name,
                            serverIconURL: guild.icon != nil ? "\(apiConfig.cdnURL)icons/\(guild.id)/\(guild.icon!).webp?size=240" : nil,
                            isLoading: loadingGuildID == guild.id,
                            onSelect: {
                                selectedGuild = guild
                            }
                        )
                    }
                    
                    ServerButton(
                        selected: false,
                        name: "Add a Server",
                        systemIconName: "plus",
                        bgColor: .green,
                        noIndicator: true,
                        onSelect: {}
                    )
                }
                .padding(.bottom, 8)
                .frame(width: 72)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .top, content: {
                // allows the top left button area to become transparent, like the sidebar
                List(){}.listStyle(.sidebar).frame(width: 72, height: 0)
                    .offset(y: -10)
                // this overlay applies a border on the bottom edge of the view
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color(nsColor: .separatorColor)), alignment: .top)
            })
            
            
            ServerView(guild: $selectedGuild)
        }
        .environmentObject(audioManager)
        .onChange(of: selectedGuild) { _ in
            guard let id = selectedGuild?.id else { return }
            UserDefaults.standard.set(id, forKey: "lastSelectedGuild")
        }
        .onChange(of: state.loadingState, perform: { state in
            if state == .gatewayConn {
                if let lGID = UserDefaults.standard.string(forKey: "lastSelectedGuild") {
                    if lGID == "@me" {
                        selectedGuild = makeDMGuild()
                        return
                    }
                    selectedGuild = gateway.cache.guilds!.first(where: { p in p.id == lGID }) ?? makeDMGuild()
                } else { selectedGuild = makeDMGuild() }
            }
        })
        // Using .constant to prevent dismissing
        .sheet(isPresented: .constant(state.attemptLogin)) {
            ZStack(alignment: .topLeading) {
                WebView()
                    .environmentObject(loginWVModel)
                    .frame(width: 831, height: 580)
                Button("Quit", role: .cancel) { exit(0) }.padding(8)
                
                if !loginWVModel.didFinishLoading {
                    ZStack {
                        ProgressView("Loading Discord login...")
                            .controlSize(.large)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .background(.background)
                }
            }
        }
        .onChange(of: loginWVModel.token, perform: { tk in
            if let tk = tk {
                state.attemptLogin = false
                let _ = Keychain.save(key: "token", data: tk)
                gateway.connect() // Reconnect to the socket
            }
        })
        .onAppear {
            let _ = gateway.onAuthFailure.addHandler {
                state.attemptLogin = true
                state.loadingState = .initial
                log.debug("User isn't logged in, attempting login")
            }
            let _ = gateway.onEvent.addHandler { (evt, d) in
                switch evt {
                case .ready:
                    state.loadingState = .gatewayConn
                    fallthrough
                case .resumed:
                    gateway.socket.send(op: .voiceStateUpdate, data: GatewayVoiceStateUpdate(
                        guild_id: nil,
                        channel_id: nil,
                        self_mute: state.selfMute,
                        self_deaf: state.selfDeaf,
                        self_video: false
                    ))
                default: break
                }
            }
        }
    }

    /*private func addItem() {
        withAnimation {
            let newItem = MessageItem(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }*/
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
