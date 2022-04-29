//
//  Embed.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

enum EmbedType: String, Codable {
    case rich = "rich"   // Generic embed rendered from embed attributes
    case image = "image"
    case video = "video"
    case gifVid = "gifv" // GIF rendered as video
    case article = "article"
    case link = "link"
}

struct Embed: Codable {
    let title: String?
    let type: EmbedType?
    let description: String?
    let url: String?
    let timestamp: ISOTimestamp?
    let color: Int?
    let footer: EmbedFooter?
    let image: EmbedMedia?
    let thumbnail: EmbedMedia?
    let video: EmbedMedia?
    let provider: EmbedProvider?
    let author: EmbedAuthor?
    let fields: [EmbedField]?
    var id: String {
        get {
            return "\(title ?? "")\(description ?? "")\(url ?? "")\(String(color ?? 0))\(timestamp ?? "")"
        }
        set {}
    }
}

struct EmbedFooter: Codable {
    let text: String
    let icon_url: String?
    let proxy_icon_url: String?
}

struct EmbedMedia: Codable {
    let url: String
    let proxy_url: String?
    let height: Int?
    let width: Int?
}

struct EmbedProvider: Codable {
    let name: String?
    let url: String?
}

struct EmbedAuthor: Codable {
    let name: String
    let url: String?
    let icon_url: String?
    let proxy_icon_url: String?
}

struct EmbedField: Codable {
    let name: String
    let value: String
    let inline: Bool?
    var id: String {
        get { name + value }
        set {}
    }
}
