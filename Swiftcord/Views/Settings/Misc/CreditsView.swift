//
//  CreditsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 8/8/22.
//

import SwiftUI
import CachedAsyncImage

private struct MinimalContributor {
	let username: String
	let url: URL
	let avatar: URL
	let contributions: Int
}

private let contributorsCache = Cache<String, [MinimalContributor]>()

struct CreditsView: View {
	@State private var contributors: [MinimalContributor]?

    var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Credits").font(.title)

			Divider()

			HStack(spacing: 24) {
				Image(systemName: "person.fill")
					.font(.system(size: 36))
					.foregroundColor(.yellow)
					.frame(width: 36)

				VStack(alignment: .leading, spacing: 8) {
					Text("Head Developer").font(.title)
					Text("I love working on Swiftcord, and developing functional and beautiful native apps!")

					Text("Vincent Kwok _AKA_ [cryptoAlgorithm](https://github.com/cryptoAlgorithm)")
				}
				Spacer()
			}

			Divider()
			
			HStack(spacing: 24) {
				Image(systemName: "dollarsign.circle")
					.font(.system(size: 36))
					.foregroundColor(.orange)
					.frame(width: 36)

				VStack(alignment: .leading, spacing: 8) {
					Text("Sponsors").font(.title2).padding(.top, 8)
					
					Text("Sponsoring Swiftcord allows me to continue developing it!")
						.padding(.bottom, 4)

					Link("selimgr",
						 destination: URL(string: "https://github.com/selimgr")!)

					Text("Please sponsor Swiftcord on GitHub! I'll be eternally grateful <3")
						.padding(.top, 4)
						.font(.caption)
				}
			}

			Divider()

			HStack(spacing: 24) {
				Image(systemName: "person.3")
					.font(.system(size: 24)) // This icon is bigger, make its font size smaller so its width remains the same
					.foregroundColor(.green)
					.frame(width: 36)

				VStack(alignment: .leading, spacing: 8) {
					Text("Contributors").font(.title2)
					Text("Thanks to all those who made valuable contributions! Swiftcord wouldn't be where it is without your contributions!")
						.padding(.bottom, 4)

					if let contributors = contributors {
						LazyVGrid(columns: [
							GridItem(.flexible()),
							GridItem(.flexible()),
							GridItem(.flexible())
						], spacing: 4) {
							ForEach(contributors, id: \.username) { contributor in
								HStack(spacing: 4) {
									// Top 3 contributors get shown more prominently
									if contributor.contributions >= contributors[2].contributions {
										GroupBox {
											VStack {
												CachedAsyncImage(url: contributor.avatar) { phase in
													if let image = phase.image {
														image
															.resizable()
															.scaledToFill()
															.transition(.customOpacity)
															.mask(Circle())
													} else {
														Rectangle().fill(.gray.opacity(0.25)).transition(.customOpacity)
													}
												}
												.frame(width: 42, height: 42)
												Link(destination: contributor.url) {
													Text(verbatim: contributor.username).font(.title3)
												}
											}
											.padding(4)
											.frame(maxWidth: .infinity)
										}
										.padding(.bottom, 4)
									} else {
										Link(contributor.username, destination: contributor.url)
									}
								}
							}
						}
					} else {
						ProgressView("Loading contributors...")
							.progressViewStyle(.circular)
							.frame(maxWidth: .infinity)
					}
					Text("Note: Also includes some contributors from Weblate")
						.padding(.top, 4)
						.font(.caption)
						.multilineTextAlignment(.center)
				}
				Spacer()
			}
			.onAppear {
				if let cached = contributorsCache.value(forKey: "cache") {
					contributors = cached
				} else {
					Task {
						guard let contribs = try? await GitHubAPI.getRepoContributors(org: "SwiftcordApp", repo: "Swiftcord")
						else { return }
						let newMinimalContributors = contribs.map {
							MinimalContributor(
								username: $0.login,
								url: $0.html_url,
								avatar: $0.avatar_url,
								contributions: $0.contributions
							)
						}
						// Must save contributors in cache to prevent exceeding GitHub API ratelimit
						contributorsCache.insert(newMinimalContributors, forKey: "cache")
						contributors = newMinimalContributors
					}
				}
			}
			Link(destination: URL(string: "https://www.reddit.com/r/discordapp/comments/k6s89b/i_recreated_the_discord_loading_animation/")!) {
				Text("Thanks to iJayTD on Reddit for recreating the Discord loading animation and agreeing to its use in Swiftcord!").multilineTextAlignment(.leading)
			}
			Text("And finally, thanks to Discord for building such an amazing community and infrastructure!").font(.subheadline)
		}
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
