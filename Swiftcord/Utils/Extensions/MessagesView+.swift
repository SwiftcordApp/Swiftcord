//
//  MessagesView+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 31/5/22.
//

import Foundation
import DiscordKit
import DiscordKitCore

internal extension MessagesView {
	func fetchMoreMessages() {
		guard let channel = ctx.channel else { return }
		if let oldTask = viewModel.fetchMessagesTask {
			oldTask.cancel()
			viewModel.fetchMessagesTask = nil
		}

		if viewModel.loadError { viewModel.showingInfoBar = false }
		viewModel.loadError = false

		viewModel.fetchMessagesTask = Task {
			let lastMsg = viewModel.messages.last?.id

			guard let newMessages = try? await restAPI.getChannelMsgs(
				id: channel.id,
				before: lastMsg
			) else {
				try Task.checkCancellation() // Check if the task is cancelled before continuing

				viewModel.fetchMessagesTask = nil
				viewModel.loadError = true
				viewModel.showingInfoBar = true
				viewModel.infoBarData = InfoBarData(
					message: "**Messages failed to load**",
					buttonLabel: "Try again",
					color: .red,
					buttonIcon: "arrow.clockwise"
				) { fetchMoreMessages() }
				state.loadingState = .messageLoad
				return
			}
			state.loadingState = .messageLoad
			try Task.checkCancellation()

			viewModel.reachedTop = newMessages.count < 50
			viewModel.messages.append(contentsOf: newMessages)
			viewModel.fetchMessagesTask = nil
		}
	}

	func sendMessage(with message: String, attachments: [URL]) {
		viewModel.lastSentTyping = Date(timeIntervalSince1970: 0)
		viewModel.newMessage = ""
		viewModel.showingInfoBar = false

		// Create message reference if neccessary
		var reference: MessageReference? {
			if let replying = viewModel.replying {
				viewModel.replying = nil // Make sure to clear that
				return MessageReference(message_id: replying.messageID, guild_id: replying.guildID.isDM ? nil : replying.guildID)
			} else { return nil }
		}
		var allowedMentions: AllowedMentions? {
			if let replying = viewModel.replying {
				return AllowedMentions(parse: [.user, .role, .everyone], replied_user: replying.ping)
			} else { return nil }
		}

		// Workaround for some race condition, no idea why clearing the message immediately doesn't
		// successfully clear it
		DispatchQueue.main.async { viewModel.newMessage = "" }

		Task {
			do {
				_ = try await restAPI.createChannelMsg(
					message: NewMessage(
						content: message,
						allowed_mentions: allowedMentions,
						message_reference: reference,
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
				)
			} catch {
				viewModel.showingInfoBar = true
				viewModel.infoBarData = InfoBarData(
					message: "Could not send message",
					buttonLabel: "Try again",
					color: .red,
					buttonIcon: "arrow.clockwise",
					clickHandler: { sendMessage(with: message, attachments: attachments) }
				)
			}
		}
	}

	func preAttachChecks(for attachment: URL) -> Bool {
		guard let size = try? attachment.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).fileSize, size < 8*1024*1024 else {
			viewModel.newAttachmentErr = NewAttachmentError(
				title: "Your files are too powerful",
				message: "The max file size is 8MB."
			)
			return false
		}
		guard viewModel.attachments.count < 10 else {
			viewModel.newAttachmentErr = NewAttachmentError(
				title: "Too many uploads!",
				message: "You can only upload 10 files at a time!"
			)
			return false
		}
		return true
	}
}
