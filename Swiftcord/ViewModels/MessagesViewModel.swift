//
//  MessagesViewModel.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 9/8/22.
//

import SwiftUI
import DiscordKitCore

// TODO: Make this ViewModel follow best practices and actually function as a ViewModel
@MainActor class MessagesViewModel: ObservableObject {
	// For use in the UI - different from MessageReference in DiscordKit
	struct ReplyRef {
		let messageID: Snowflake
		let guildID: Snowflake
		let ping: Bool
		let authorID: Snowflake
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
	@Published var dropOver = false
	@Published var highlightMsg: Snowflake?

	func addMessage(_ message: Message) {
		withAnimation {
			messages.insert(message, at: 0)
		}
	}

	func updateMessage(_ updated: PartialMessage) {
		if let updatedIdx = messages.firstIndex(identifiedBy: updated.id) {
			messages[updatedIdx] = messages[updatedIdx].mergingWithPartialMsg(updated)
		}
	}

	func deleteMessage(_ deleted: MessageDelete) {
		withAnimation { messages.removeAll(identifiedBy: deleted.id) }
	}
	func deleteMessageBulk(_ bulkDelete: MessageDeleteBulk) {
		withAnimation {
			for msgID in bulkDelete.id {
				messages.removeAll(identifiedBy: msgID)
			}
		}
	}
}
