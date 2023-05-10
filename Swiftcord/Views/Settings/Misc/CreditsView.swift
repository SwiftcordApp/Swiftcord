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
		Section("settings.others.credits.headDev") {
			HStack {
				Image(systemName: "person")
					.font(.system(size: 36))
					.foregroundColor(.blue)
					.frame(width: 36)
				VStack {
					Text("settings.others.credits.about")
				}
			}
			Text("settings.others.credits.whoAmI")
		}

		Section {
			HStack {
				Image(systemName: "dollarsign.circle")
					.font(.system(size: 30))
					.foregroundColor(.orange)
					.frame(width: 36)
				Text("settings.others.credits.sponsor.desc").padding(.bottom, 4)
			}
		} header: {
			Text("settings.others.credits.sponsor")
		} footer: {
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
						AnalyticsWrapper.event(type: .supporterCTAClick, properties: ["type": "github"])
					} label: {
						Text("settings.others.credits.sponsor.gh")
					}.buttonStyle(FlatButtonStyle(customBase: .white))
					Button {
						openURL(URL(string: "https://patreon.com/cryptoAlgo")!)
						AnalyticsWrapper.event(type: .supporterCTAClick, properties: ["type": "patreon"])
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

		Section {
			HStack {
				Image(systemName: "person.2")
					.font(.system(size: 24)) // This icon is bigger, make its font size smaller so its width remains the same
					.foregroundColor(.green)
					.frame(width: 36)
				Text("settings.others.credits.contrib.desc")
			}

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
										.padding(6)
										.frame(maxWidth: .infinity)
									}
								}
								.frame(maxWidth: .infinity)
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
		} header: {
			Text("settings.others.credits.contrib")
		} footer: {
			Text("settings.others.credits.contrib.note").font(.caption)
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

		Section {
			/*HStack(alignment: .top, spacing: 24) {
				VStack(alignment: .leading, spacing: 8) {
					Group {
						Text("settings.others.credits.sponsor.tier3").font(.title3).padding(.top, 8)
						LazyVGrid(columns: [
							GridItem(.flexible()),
							GridItem(.flexible())
						], spacing: 4) {
							GroupBox {
								HStack(alignment: .top, spacing: 8) {
									BetterImageView(url: URL(string: "https://cdn.discordapp.com/avatars/164066880250839040/454495419ffe4dfeb7ea91f82eecfe47.png"))
										.frame(width: 128, height: 128)
									VStack(alignment: .leading) {
										Text(verbatim: "kallisti").font(.title)
										Text("[midnight.town](https://midnight.town)")
										Spacer()
										Text("First red-hot supporter!").font(.italic(.body)())
									}.padding(8)
									Spacer()
								}
								.frame(maxWidth: .infinity)
								.padding(-4)
							}
							GroupBox {
								HStack(spacing: 12) {
									Image(systemName: "plus.app")
										.font(.system(size: 64))
										.foregroundColor(.orange)
									VStack(alignment: .leading, spacing: 8) {
										Text("Become a Sponsor").font(.title)
										Text("Find out how you can [support Swiftcord](https://github.com/sponsors/cryptoAlgorithm)!")
										Spacer()
									}
									Spacer()
								}
								.padding(4)
							}
						}
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

			Divider()*/

			Text("settings.others.credits.misc.anim").multilineTextAlignment(.leading)
			Text("settings.others.credits.misc.discord").font(.callout).foregroundColor(.secondary)
		}
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
