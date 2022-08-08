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
	@State private var addPulseScale = 1.0
	@Environment(\.openURL) var openURL

    var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Credits").font(.title)

			Divider()

			HStack(alignment: .top, spacing: 24) {
				Image(systemName: "person")
					.font(.system(size: 36))
					.foregroundColor(.blue)
					.frame(width: 36)

				VStack(alignment: .leading, spacing: 8) {
					Text("Head Developer").font(.title)
					Text("I love working on Swiftcord, and developing functional and beautiful native apps!")

					Text("Vincent Kwok _AKA_ [cryptoAlgorithm](https://github.com/cryptoAlgorithm)")
				}
				Spacer()
			}

			Divider()
			
			HStack(alignment: .top, spacing: 24) {
				Image(systemName: "dollarsign.circle")
					.font(.system(size: 36))
					.foregroundColor(.orange)
					.frame(width: 36)

				VStack(alignment: .leading, spacing: 8) {
					Text("Sponsors").font(.title2)

					Text("Consider supporting me through [GitHub Sponsors](https://github.com/sponsors/cryptoAlgorithm) or [Patreon](https://patreon.com/cryptoAlgo)! It would help ensure this project has a stable future :)")
						.padding(.bottom, 4)

					Group {
						Text("Red-hot Supporter 🔥").font(.title3).padding(.top, 8)
						VStack(spacing: 8) {
							Image(systemName: "plus.circle")
								.font(.system(size: 64))
								.scaleEffect(addPulseScale)
								.animation(
									.easeInOut(duration: 0.6)
									.repeatForever(autoreverses: true),
									value: addPulseScale
								)
								.onAppear { addPulseScale = 1.15 }
							Text("Become a sponsor").font(.largeTitle)
							Text("Your name, and an image and bio of your choice could be here! You'll be directly supporting the development of Swiftcord with your sponsorship!").multilineTextAlignment(.center)

							HStack(spacing: 16) {
								Button {
									openURL(URL(string: "https://github.com/sponsors/cryptoAlgorithm")!)
								} label: {
									Text("GitHub Sponsors")
								}.buttonStyle(FlatButtonStyle(customBase: .white))
								Button {
									openURL(URL(string: "https://patreon.com/cryptoAlgo")!)
								} label: {
									Text("Patreon")
								}.buttonStyle(FlatButtonStyle(customBase: .white))
							}.padding(.top, 8)
						}
						.padding(16)
						.frame(maxWidth: .infinity)
						.background(
							LinearGradient(
								gradient: Gradient(
									stops: [
										.init(color: .init("NitroGradientStart"), location: 0),
										.init(color: .init("NitroGradientMiddle"), location: 0.5),
										.init(color: .init("NitroGradientEnd"), location: 1)
									]
								),
								startPoint: .topLeading,
								endPoint: .bottomTrailing
							)
						)
						.cornerRadius(7)
					}

					Group {
						Text("Amazing Supporter 🤯").font(.title3).padding(.top, 8)
						HStack(spacing: 8) {
							BetterImageView(url: URL(string: "https://cxt.sh/assets/img/pfp.png"))
								.frame(width: 36, height: 36)
								.clipShape(Circle())
							Text(verbatim: "cxt").font(.monospaced(.system(size: 18))())
						}
					}

					Group {
						Text("Extremely Cool Supporter 🧊").font(.title3).padding(.top, 8)

						Text(verbatim: "selimgr").font(.monospaced(.body)())
						Text(verbatim: "An extremely generous anonymous supporter")
					}

					Text("Please sponsor Swiftcord on GitHub! I'll be eternally grateful <3")
						.padding(.top, 4)
						.font(.caption)
				}
			}

			Divider()

			HStack(alignment: .top, spacing: 24) {
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
							// Only display the 12 top contributors by contributions
							ForEach(contributors.prefix(12), id: \.username) { contributor in
								HStack(spacing: 4) {
									// Top 3 contributors get shown more prominently
									if contributor.contributions >= contributors[2].contributions {
										Button {
											openURL(contributor.url)
										} label: {
											GroupBox {
												VStack {
													BetterImageView(url: contributor.avatar)
														.frame(width: 42, height: 42)
														.clipShape(Circle())
													Text(verbatim: contributor.username).font(.title3)
												}
												.padding(4)
												.frame(maxWidth: .infinity)
											}
										}
										.padding(.bottom, 4)
										.buttonStyle(.plain)
									} else {
										Link(contributor.username, destination: contributor.url)
									}
								}
							}
						}.frame(maxWidth: .infinity)
						if contributors.count > 12 {
							Link(
								"+ \(contributors.count - 12) contributors",
								destination: URL(string: "https://github.com/SwiftcordApp/Swiftcord/graphs/contributors")!
							)
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
			Text("Thanks to iJayTD on Reddit for [recreating the Discord loading animation](https://www.reddit.com/r/discordapp/comments/k6s89b/i_recreated_the_discord_loading_animation) and agreeing to its use in Swiftcord!").multilineTextAlignment(.leading)
			Text("And finally, thanks to Discord for building such an amazing community and infrastructure!").font(.subheadline)
		}
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
