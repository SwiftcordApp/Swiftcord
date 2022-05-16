//
//  Embed.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public enum EmbedType: String, Codable {
    case rich = "rich"   // Generic embed rendered from embed attributes
    case image = "image"
    case video = "video"
    case gifVid = "gifv" // GIF rendered as video
    case article = "article"
    case link = "link"
}

public struct Embed: Codable, Identifiable {
    public let title: String?
    public let type: EmbedType?
    public let description: String?
    public let url: String?
    public let timestamp: ISOTimestamp?
    public let color: Int?
    public let footer: EmbedFooter?
    public let image: EmbedMedia?
    public let thumbnail: EmbedMedia?
    public let video: EmbedMedia?
    public let provider: EmbedProvider?
    public let author: EmbedAuthor?
    public let fields: [EmbedField]?
    public var id: String {
		"\(title ?? "")\(description ?? "")\(url ?? "")\(String(color ?? 0))\(timestamp ?? "")"
    }
}

public struct EmbedFooter: Codable {
    public let text: String
    public let icon_url: String?
    public let proxy_icon_url: String?
}

public struct EmbedMedia: Codable {
    public let url: String
    public let proxy_url: String?
    public let height: Int?
    public let width: Int?
}

public struct EmbedProvider: Codable {
    public let name: String?
    public let url: String?
}

public struct EmbedAuthor: Codable {
    public let name: String
    public let url: String?
    public let icon_url: String?
    public let proxy_icon_url: String?
}

public struct EmbedField: Codable, Identifiable {
    public let name: String
    public let value: String
    public let inline: Bool?
    public var id: String {
		name + value
    }
}
