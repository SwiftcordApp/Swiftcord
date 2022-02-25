//
//  NewMessage.swift
//  Native Discord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation

struct NewMessage: Codable, GatewayData {
    let content: String?
    let tts: Bool?
    let embeds: [Embed]?
    let allowed_mentions: AllowedMentions?
    let message_reference: MessageReference?
    let components: [MessageComponent]?
    let sticker_ids: [Snowflake]?
    // file[n] // Handle file uploading later
    // attachments
    // let payload_json: Codable? // Handle this later
    let flags: Int?
}
