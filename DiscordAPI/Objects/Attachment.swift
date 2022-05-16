//
//  Attachment.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

struct Attachment: Codable, Identifiable {
    let id: Snowflake
    let filename: String
    let description: String?
    let content_type: String? // Attachment's MIME type
    let size: Int // Size of file in bytes
    let url: String // Source URL of file
    let proxy_url: String // A proxied URL of the file
    let height: Int? // Height of file (if image)
    let width: Int? // Width of file (if image)
    let ephemeral: Bool?
}
