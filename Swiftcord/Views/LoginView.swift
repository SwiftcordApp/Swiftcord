//
//  Login.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import SwiftUI
import DiscordKit
import DiscordKitCore

struct LoginView: View {
	@StateObject var loginWVModel: WebViewModel = WebViewModel(link: "https://canary.discord.com/login")
	@State var tokenView: Bool = false
	@State var tokenCount = 0
	@State var tokenString: String = ""

	@EnvironmentObject var gateway: DiscordGateway
	@EnvironmentObject var restAPI: DiscordREST
	@EnvironmentObject var state: UIState

    var body: some View {
		ZStack {
			if !tokenView {
				WebView()
					.environmentObject(loginWVModel)

				if !loginWVModel.didFinishLoading {
					ZStack {
						ProgressView("Loading Discord login...")
							.controlSize(.large)
							.frame(maxWidth: .infinity, maxHeight: .infinity)
					}.background(.background)
				}
			}

			Button("Token Login") {
				tokenCount += 1
				if tokenCount >= 5 {
					tokenView = !tokenView
				}
			}
			.keyboardShortcut("t", modifiers: [.command, .shift])
			.hidden()

			if tokenView {
				VStack {
					Text("login.token.title")
						.font(.title)
					SecureField("login.token.input", text: $tokenString)
					HStack {
						Button("login.token.back") {
							tokenView = !tokenView
						}
						Button("login.token.login") {
							loginWVModel.token = tokenString
						}
					}
				}.padding()
			}
		}
		.frame(minWidth: 850, idealWidth: 950, minHeight: 500, idealHeight: 620)
		.navigationTitle("Login")
		.onChange(of: loginWVModel.token) { token in
			if let token = token {
				Keychain.save(key: SwiftcordApp.tokenKeychainKey, data: token)
				gateway.connect(token: token) // Reconnect to the socket with the new token
				restAPI.setToken(token: token)
				state.attemptLogin = false
			}
		}
    }
}
