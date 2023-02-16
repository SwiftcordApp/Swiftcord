//
//  Login.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import SwiftUI
import DiscordKit

struct LoginView: View {
	@StateObject var loginWVModel: WebViewModel = WebViewModel(link: "https://discord.com/login")
	@State var tokenView: Bool = false
	@State var tokenCount = 0
	@State var tokenString: String = ""

	var shrink = false
	var showQR = false
	var onLoggedIn: (() -> Void)?

	@EnvironmentObject var gateway: DiscordGateway
	@EnvironmentObject var state: UIState
	@EnvironmentObject var acctManager: AccountSwitcher

    var body: some View {
		ZStack {
			if !tokenView {
				WebView(shrink: shrink, shrunkShowingQR: showQR)
					.environmentObject(loginWVModel)

				if !loginWVModel.didFinishLoading {
					ZStack {
						ProgressView("Loading Discord login...")
							.controlSize(.large)
							.frame(maxWidth: .infinity, maxHeight: .infinity)
					}.background(.background)
				}
			} else {
				VStack {
					Text("login.token.title")
						.font(.title)
					SecureField("login.token.input", text: $tokenString)
					HStack {
						Button("login.token.back") {
							tokenView.toggle()
						}
						Button("login.token.login") {
							loginWVModel.token = tokenString
						}
					}
				}.padding()
			}

			Button("Token Login") {
				tokenCount += 1
				if tokenCount >= 5 {
					tokenView.toggle()
				}
			}
			.keyboardShortcut("t", modifiers: [.command, .shift])
			.hidden()
		}
		.frame(minWidth: shrink ? 450 : 850, idealWidth: 950, minHeight: 500, idealHeight: 620)
		.onAppear {
			AnalyticsWrapper.event(type: .impressionLogin)
		}
		.onChange(of: loginWVModel.token) { token in
			if let token = token {
				acctManager.setPendingToken(token: token)
				if state.loadingState == .messageLoad { // Switch account
					gateway.disconnect()
					state.loadingState = .initial
				}
				gateway.connect(token: token) // Reconnect to the socket with the new token
				restAPI.setToken(token: token)
				state.attemptLogin = false
				if let onLoggedIn = onLoggedIn { onLoggedIn() }
			}
		}
    }
}
