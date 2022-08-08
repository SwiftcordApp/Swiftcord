//
//  ghAPIs.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 16/6/22.
//

import Foundation

/// A rudimentary GitHub API "implementation" that only implements the specific
/// endpoints required for various functionality in Swiftcord
///
/// I'm well aware better implementations of GitHub's API exist, for example
/// [OctoKit](https://github.com/nerdishbynature/octokit.swift),
/// but I do not want to rely on yet another package for something only sparingly used.
struct GitHubAPI {
	private static let baseURL = URL(string: "https://api.github.com")!

	static func getReleaseByTag(
		org: String,
		repo: String,
		tag: String
	) async throws -> GHRelease {
		let url = GitHubAPI.baseURL
			.appendingPathComponent("repos")
			.appendingPathComponent(org)
			.appendingPathComponent(repo)
			.appendingPathComponent("releases")
			.appendingPathComponent("tags")
			.appendingPathComponent(tag)

		return try await makeReq(url: url)
	}

	static func getRepoContributors(
		org: String,
		repo: String
	) async throws -> [GHRepoContributor] {
		let url = GitHubAPI.baseURL
			.appendingPathComponent("repos")
			.appendingPathComponent(org)
			.appendingPathComponent(repo)
			.appendingPathComponent("contributors")

		return try await makeReq(url: url)
	}

	static func makeReq<R: Codable>(url: URL) async throws -> R {
		var req = URLRequest(url: url)
		req.setValue("application/vnd.github+json", forHTTPHeaderField: "accept")
		let (data, _) = try await URLSession.shared.data(for: req)

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return try decoder.decode(R.self, from: data)
	}
}
