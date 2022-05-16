//
//  NewMessage.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation

public struct NewAttachment: Codable {
    public let id: String // Will not be a valid snowflake for new attachments
    public let filename: String

	public init(id: String, filename: String) {
		self.id = id
		self.filename = filename
	}
}

public struct NewMessage: Codable {
    public let content: String?
    public let tts: Bool?
    public let embeds: [Embed]?
    public let allowed_mentions: AllowedMentions?
    public let message_reference: MessageReference?
    public let components: [MessageComponent]?
    public let sticker_ids: [Snowflake]?
    public let attachments: [NewAttachment]?
    // file[n] // Handle file uploading later
    // attachments
    // let payload_json: Codable? // Handle this later
    public let flags: Int?

	public init(content: String?, tts: Bool? = false, embeds: [Embed]? = nil, allowed_mentions: AllowedMentions? = nil, message_reference: MessageReference? = nil, components: [MessageComponent]? = nil, sticker_ids: [Snowflake]? = nil, attachments: [NewAttachment]? = nil, flags: Int? = nil) {
		self.content = content
		self.tts = tts
		self.embeds = embeds
		self.allowed_mentions = allowed_mentions
		self.message_reference = message_reference
		self.components = components
		self.sticker_ids = sticker_ids
		self.attachments = attachments
		self.flags = flags
	}
}
