//
//  GitHubStructs.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 16/6/22.
//

import Foundation

enum GHUserType: String, Codable {
	case user = "User"
}

struct GHAuthor: Codable {
	let login: String
	let id: Int
	let avatar_url: URL
	let url: URL
	let html_url: URL
	let followers_url: URL
	let following_url: String // URL is not a valid URL
	let gists_url: String
	let starred_url: String
	let subscriptions_url: URL
	let organizations_url: URL
	let repos_url: URL
	let events_url: String
	let received_events_url: URL
	let type: GHUserType
	let site_admin: Bool
}

struct GHReleaseAsset: Codable {
	let url: URL
	let id: Int
	let name: String
	let uploader: GHAuthor
	let content_type: String
	let state: String
	let size: Int
	let download_count: Int
	let created_at: Date
	let updated_at: Date
	let browser_download_url: URL
}

struct GHRelease: Codable {
	let url: URL
	let assets_url: URL
	let upload_url: String
	let html_url: URL
	let id: Int
	let author: GHAuthor
	let tag_name: String
	let target_commitish: String
	let name: String
	let draft: Bool
	let prerelease: Bool
	let created_at: Date
	let published_at: Date
	let assets: [GHReleaseAsset]
	let tarball_url: URL
	let zipball_url: URL
	let body: String
	let mentions_count: Int
}

struct GHRepoContributor: Codable {
	let login: String
	let id: Int
	let node_id: String
	let avatar_url: URL
	let gravatar_id: String?
	let url: URL
	let html_url: URL
	let followers_url: URL
	let following_url: String
	let gists_url: String
	let starred_url: String
	let subscriptions_url: URL
	let organizations_url: URL
	let repos_url: URL
	let events_url: String
	let received_events_url: URL
	let type: String
	let site_admin: Bool
	let contributions: Int /// Number of commits this user has made
	let email: String?
}
