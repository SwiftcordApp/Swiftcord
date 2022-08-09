//
//  MessagesViewModel.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 9/8/22.
//

import SwiftUI
import DiscordKitCommon

extension MessagesView {
	@MainActor class ViewModel: ObservableObject {
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
		@Published var replyingID: Snowflake?
		@Published var messageInputHeight = 0.0
		@Published var dropOver = false
		@Published var highlightMsg: Snowflake?
		
		
	}
}
