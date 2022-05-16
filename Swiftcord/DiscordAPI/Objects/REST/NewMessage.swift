//
//  NewMessage.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation

struct NewAttachment: Codable {
    let id: String // Will not be a valid snowflake for new attachments
    let filename: String
}

struct NewMessage: Codable {
    let content: String?
    var tts: Bool? = false
    var embeds: [Embed]? = nil
    var allowed_mentions: AllowedMentions? = nil
    var message_reference: MessageReference? = nil
    var components: [MessageComponent]? = nil
    var sticker_ids: [Snowflake]? = nil
    var attachments: [NewAttachment]? = nil
    // file[n] // Handle file uploading later
    // attachments
    // let payload_json: Codable? // Handle this later
    var flags: Int? = nil
}
