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
			Text("settings.others.credits").font(.title)

			Divider()

			HStack(alignment: .top, spacing: 24) {
				Image(systemName: "person")
					.font(.system(size: 36))
					.foregroundColor(.blue)
					.frame(width: 36)

				VStack(alignment: .leading, spacing: 8) {
					Text("settings.others.credits.headDev").font(.title)
					Text("settings.others.credits.about")

					Text("settings.others.credits.whoAmI")
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
					Text("settings.others.credits.sponsor").font(.title2)

					Text("settings.others.credits.sponsor.desc").padding(.bottom, 4)

					Group {
						Text("settings.others.credits.sponsor.tier3").font(.title3).padding(.top, 8)
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
							Text("settings.others.credits.sponsor.engage.header").font(.largeTitle)
							Text("settings.others.credits.sponsor.engage.body").multilineTextAlignment(.center)

							HStack(spacing: 16) {
								Button {
									openURL(URL(string: "https://github.com/sponsors/cryptoAlgorithm")!)
								} label: {
									Text("settings.others.credits.sponsor.gh")
								}.buttonStyle(FlatButtonStyle(customBase: .white))
								Button {
									openURL(URL(string: "https://patreon.com/cryptoAlgo")!)
								} label: {
									Text("settings.others.credits.sponsor.patreon")
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
						Text("settings.others.credits.sponsor.tier2").font(.title3).padding(.top, 8)
						HStack(spacing: 8) {
							BetterImageView(url: URL(string: "https://cxt.sh/assets/img/pfp.png"))
								.frame(width: 36, height: 36)
								.clipShape(Circle())
							Text(verbatim: "cxt").font(.monospaced(.system(size: 18))())
						}
					}

					Group {
						Text("settings.others.credits.sponsor.tier1").font(.title3).padding(.top, 8)

						Text(verbatim: "selimgr").font(.monospaced(.body)())
						Text("settings.others.credits.contrib.anon")
					}
				}
			}

			Divider()

			HStack(alignment: .top, spacing: 24) {
				Image(systemName: "person.3")
					.font(.system(size: 24)) // This icon is bigger, make its font size smaller so its width remains the same
					.foregroundColor(.green)
					.frame(width: 36)

				VStack(alignment: .leading, spacing: 8) {
					Text("settings.others.credits.contrib").font(.title2)
					Text("settings.others.credits.contrib.desc").padding(.bottom, 4)

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
								"\(contributors.count - 12) settings.others.credits.contrib.more",
								destination: URL(string: "https://github.com/SwiftcordApp/Swiftcord/graphs/contributors")!
							)
						}
					} else {
						ProgressView("settings.others.credits.contrib.loading")
							.progressViewStyle(.circular)
							.frame(maxWidth: .infinity)
					}
					Text("settings.others.credits.contrib.note")
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
			Text("settings.others.credits.misc.anim").multilineTextAlignment(.leading)
			Text("settings.others.credits.misc.discord").font(.subheadline)
		}
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
