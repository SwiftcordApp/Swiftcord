//
//  MessagesView+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 31/5/22.
//

import Foundation
import DiscordKit

extension MessagesView {
	internal func fetchMoreMessages() {
		guard let channel = ctx.channel else { return }
		if let oldTask = fetchMessagesTask {
			oldTask.cancel()
			fetchMessagesTask = nil
		}

		if loadError { showingInfoBar = false }
		loadError = false

		fetchMessagesTask = Task {
			let lastMsg = messages.isEmpty ? nil : messages[messages.count - 1].id

			guard let newMessages = await DiscordAPI.getChannelMsgs(
				id: channel.id,
				before: lastMsg
			) else {
				try Task.checkCancellation() // Check if the task is cancelled before continuing

				fetchMessagesTask = nil
				loadError = true
				showingInfoBar = true
				infoBarData = InfoBarData(
					message: "Messages failed to load",
					buttonLabel: "Try again",
					color: .red,
					buttonIcon: "arrow.clockwise",
					clickHandler: { fetchMoreMessages() }
				)
				state.loadingState = .messageLoad
				return
			}
			state.loadingState = .messageLoad
			try Task.checkCancellation()

			reachedTop = newMessages.count < 50
			messages.append(contentsOf: newMessages)
			fetchMessagesTask = nil
		}
	}

	internal func sendMessage(with message: String, attachments: [URL]) {
		lastSentTyping = Date(timeIntervalSince1970: 0)
		newMessage = ""
		showingInfoBar = false
		Task {
			guard (await DiscordAPI.createChannelMsg(
				message: NewMessage(
					content: message,
					attachments: attachments.isEmpty ? nil : attachments.enumerated()
						.map { (idx, attachment) in
							NewAttachment(
								id: String(idx),
								filename: (try? attachment.resourceValues(forKeys: [URLResourceKey.nameKey]).name) ?? UUID().uuidString
							)
						}
				),
				attachments: attachments,
				id: ctx.channel!.id
			)) != nil else {
				showingInfoBar = true
				infoBarData = InfoBarData(
					message: "Could not send message",
					buttonLabel: "Try again",
					color: .red,
					buttonIcon: "arrow.clockwise",
					clickHandler: { sendMessage(with: message, attachments: attachments) }
				)
				return
			}
		}
	}

	internal func preAttachChecks(for attachment: URL) -> Bool {
		guard let size = try? attachment.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).fileSize, size < 8*1024*1024 else {
			newAttachmentErr = NewAttachmentError(
				title: "Your files are too powerful",
				message: "The max file size is 8MB."
			)
			return false
		}
		guard attachments.count < 10 else {
			newAttachmentErr = NewAttachmentError(
				title: "Too many uploads!",
				message: "You can only upload 10 files at a time!"
			)
			return false
		}
		return true
	}
}
