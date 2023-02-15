//
//  MergePartialMessage.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/3/22.
//
//  Merges a PartialMessage and Message
//  Fields from PartialMessage are favored

import Foundation
import DiscordKitCore

extension Message {
	func mergingWithPartialMsg(_ partial: PartialMessage) -> Message {
		Message(
			id: id,
			channel_id: channel_id,
			guild_id: guild_id,
			author: partial.author ?? author,
			member: partial.member ?? member,
			content: partial.content ?? content,
			timestamp: timestamp,
			edited_timestamp: partial.edited_timestamp ?? edited_timestamp,
			tts: partial.tts ?? tts,
			mention_everyone: partial.mention_everyone ?? mention_everyone,
			mentions: partial.mentions ?? mentions,
			mention_roles: partial.mention_roles ?? mention_roles,
			mention_channels: partial.mention_channels ?? mention_channels,
			attachments: partial.attachments ?? attachments,
			embeds: partial.embeds ?? embeds,
			reactions: partial.reactions ?? reactions,
			pinned: partial.pinned ?? pinned,
			webhook_id: webhook_id,
			type: type,
			activity: partial.activity ?? activity,
			application: partial.application ?? application,
			application_id: partial.application_id ?? application_id,
			message_reference: message_reference,
			flags: partial.flags ?? flags,
			referenced_message: partial.referenced_message ?? referenced_message,
			interaction: partial.interaction ?? interaction,
			thread: partial.thread ?? thread,
			components: partial.components ?? components,
			sticker_items: partial.sticker_items ?? sticker_items
		)
    }
}
