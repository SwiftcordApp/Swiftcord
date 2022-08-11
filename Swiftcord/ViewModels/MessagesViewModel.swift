//
//  MessagesViewModel.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 9/8/22.
//

import SwiftUI
import DiscordKitCommon

extension MessagesView {
	// TODO: Make this ViewModel follow best practices and actually function as a ViewModel
	@MainActor class ViewModel: ObservableObject {
		// For use in the UI - different from MessageReference in DiscordKit
		struct ReplyRef {
			let messageID: Snowflake
			let guildID: Snowflake
			let ping: Bool // Currently unused
			let authorUsername: String
		}

		@Published var reachedTop = false
		@Published var messages: [Message] = []
		@Published var newMessage = " "
		@Published var attachments: [URL] = []
		@Published var showingInfoBar = false
		@Published var loadError = false
		@Published var infoBarData: InfoBarData?
		@Published var fetchMessagesTask: Task<(), Error>?
		@Published var lastSentTyping = Date(timeIntervalSince1970: 0)
		@Published var newAttachmentErr: NewAttachmentError?
		@Published var replying: ReplyRef?
		@Published var messageInputHeight = 0.0
		@Published var dropOver = false
		@Published var highlightMsg: Snowflake?
	}
}
