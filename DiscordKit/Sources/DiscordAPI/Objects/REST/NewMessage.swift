//
//  NewMessage.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation

public struct NewMessage: Codable {
	public let content: String?
	public let tts: Bool?
	public let embeds: [Embed]?
	public let allowed_mentions: AllowedMentions?
	public let message_reference: MessageReference?
	public let components: [MessageComponent]?
	public let sticker_ids: [Snowflake]?
    // file[n] // Handle file uploading later
    // attachments
    // let payload_json: Codable? // Handle this later
	public var flags: Int? = nil

	public init(content: String?,
				tts: Bool? = false,
				embeds: [Embed]? = nil,
				allowed_mentions: AllowedMentions? = nil,
				message_reference: MessageReference? = nil,
				components: [MessageComponent]? = nil,
				sticker_ids: [Snowflake]? = nil,
				flags: Int? = nil) {
		self.content = content
		self.tts = tts
		self.embeds = embeds
		self.allowed_mentions = allowed_mentions
		self.message_reference = message_reference
		self.components = components
		self.sticker_ids = sticker_ids
		self.flags = flags
	}
}
