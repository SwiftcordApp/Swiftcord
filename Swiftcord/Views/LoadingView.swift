//
//  LoadingView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/2/22.
//

import SwiftUI
import DiscordKit
import DiscordKitCore
import Reachability

struct LoadingView: View {
    @EnvironmentObject var state: UIState
	@EnvironmentObject var gateway: DiscordGateway
	@EnvironmentObject var restAPI: DiscordREST

	let keyPrefixesToRemove = [
		"lastCh.",
		"local.",
		"lastSelectedGuild",
		"showSendBtn",
		"stickerAlwaysAnim",
		"theme",
		"ttsRate"
	]

	private func logOut() {
		for key in UserDefaults.standard.dictionaryRepresentation().keys {
			for toRemove in keyPrefixesToRemove {
				if key.prefix(toRemove.count) == toRemove {
					UserDefaults.standard.removeObject(forKey: key)
					break
				}
			}
		}
		gateway.logout()
		Task { await restAPI.logOut() }
		Keychain.remove(key: SwiftcordApp.tokenKeychainKey)
	}

	@Environment(\.colorScheme) private var colorScheme

    private let loadingTips = [
        "You can use Streamer Mode to hide personal details while streaming.",
        "You can type /tableflip and /unflip to spice up your messages.",
        "Characters like @, #, ! and * will narrow Quick Switcher results.",
        "Click a server name in the emoji picker to hide that server\'s emojis.",
        "Hover a GIF and click the star to save it to your favourites.",
        "The top-most role for a user defines that user\'s colour.",
        "A red mic icon means that person has been muted by a server admin.",
        "You can temporarily mute a server or channel by right-clicking it.",
        "Click your avatar in the lower-left corner to set a custom status.",
        "Group DMs can have up to ten members.",
        "Click the compass in your server list to find new servers.",
        "Drag and drop servers on top of each other to create server folders.",
        "Type /tenor or /giphy + anything to find a GIF for that topic!",
        "Share what you\'re playing by using the game activity settings.",
        "Highlight text in your chat bar to bold, use italics and more.",
        "Hide muted channels in a server by right-clicking the server name.",
        "Customise Discord\'s appearance in the user settings menu.",
        "Link your favourite social media accounts in the connections settings.",
        "You can create channel categories to group and organise your channels.",
        "You can join up to 100 servers, and up to 200 servers with Nitro!",
        "You can drag and drop files onto Discord to upload them.",
        "Change each participant\'s volume by right-clicking them in a call.",
        "Right click to pin messages in a channel or DM to save them for later.",
        "Type a plus sign before an emoji name to turn it into a reaction.",
        "You can type /nick to quickly change your nickname in a server.",
        "You can type / to view bot commands and other built-in commands",
        "You can type !!{asterisks}!! around your words to make them **bold**."
    ]

    @State private var displayedTip = ""
	@State private var showLogoutButton = false
	@State private var showNoInternet = false

    var body: some View {
		let loading = state.loadingState != .messageLoad

        VStack(spacing: 4) {
            LottieView(
                name: "discord-loading-animation",
                play: .constant(loading),
                width: 280,
                height: 280
            )
            .frame(width: 280, height: 150)
            .lottieLoopMode(.loop)
			.if(colorScheme == .light) { view in view.colorInvert() }

			if Int.random(in: 0..<1000000000) != 0 {
				Text("loader.tip.header").font(.headline).textCase(.uppercase)
				Text(.init(displayedTip))
					.multilineTextAlignment(.center)
					.padding(.top, 8)
					.frame(maxWidth: 320)
					.onAppear {
						displayedTip = loadingTips.randomElement()! // Will never be nil because loadingTips can never be empty

						withAnimation {
							let connection = try? Reachability(hostname: "https://discord.com/").connection
							if connection == .unavailable {
								showNoInternet = true
							} else {
								DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
									showLogoutButton = true
								}
							}
						}
					}
			} else {
				Text("Please wait warmly...").font(.headline)
					.onAppear {
						withAnimation {
							let connection = try? Reachability(hostname: "https://discord.com/").connection
							if connection == .unavailable {
								showNoInternet = true
							} else {
								DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
									showLogoutButton = true
								}
							}
						}
					}
			}

			if showLogoutButton {
				Button("loader.panic.logout") {
					logOut()
					state.attemptLogin = true
				}.padding()
			}

			if showNoInternet {
				if loading {
					Text("\(Image(systemName: "bolt.horizontal.fill")) No Network Connectivity")
						.font(.headline)
						.foregroundColor(.red)
						.padding(.top)
					Link("Check Discord Status", destination: URL(string: "https://discordstatus.com")!)
				}
			}
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(loading)
        .background(Color(NSColor.windowBackgroundColor))
		.opacity(loading ? 1 : 0)
        .scaleEffect(loading ? 1 : 2)
        .animation(.interpolatingSpring(stiffness: 200, damping: 120), value: loading)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
