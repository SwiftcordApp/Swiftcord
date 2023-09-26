//
//  EmbedView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/2/22.
//

import SwiftUI
import CachedAsyncImage
import DiscordKitCore

struct RichEmbedView: View {
	let embed: Embed

	private func groupFields(_fields: [EmbedField]) -> [[EmbedField]] {
		var newArray = [[EmbedField]]()

		var count = 0
		var array_i = 0

		_fields.forEach { field in
			if field.inline == true {
				if count == 0 {
					newArray.append([])
					array_i = newArray.count - 1
				}
				newArray[array_i].append(field)
				count = (count+1 == 3) ? 0 : count + 1
			} else {
				if count > 0 { count = 0 }
				newArray.append([field])
			}
		}

		return newArray
	}

	@ViewBuilder
	private func embedMedia(image: EmbedMedia) -> some View {
		let width: Double = image.width != nil ? Double(min(400, image.width!)) : 400.0
		let height: Double = (image.width != nil && image.height != nil)
		? Double(width) / (Double(image.width!) / Double(image.height!))
		: 216
		AttachmentImage(width: width, height: height, scale: 1, url: URL(string: image.proxy_url ?? image.url)!)
	}

	var body: some View {
		GroupBox {
			// The width of media present to constrain width to
			let mediaWidth = embed.image?.width ?? embed.thumbnail?.width
			VStack(alignment: .leading, spacing: 8) {
				// MARK: - Author
				if let author = embed.author {
					HStack(alignment: .center, spacing: 8) {
						if let iconURL = author.icon_url {
							let width = 24.0
							let height = 24.0
							CachedAsyncImage(url: URL(string: iconURL)) { phase in
								if let image = phase.image { image.resizable().scaledToFill() } else {
									Spacer().frame(width: width, height: height)
								}
							}
							.frame(width: width, height: height)
							.cornerRadius(12)
						}

						let authorName = author.name
						if let urlStr = author.url, let url = URL(string: urlStr) {
							Link(destination: url) {
								Text(authorName).font(.headline)
							}.foregroundColor(.primary)
						} else {
							Text(authorName)
								.font(.headline)
								.textSelection(.enabled)
						}
					}
				}
				// MARK: Provider
				if let provider = embed.provider, let providerName = provider.name {
					if let urlStr = provider.url, let url = URL(string: urlStr) {
						Link(destination: url) {
							Text(providerName).font(.headline)
						}.foregroundColor(.primary)
					} else {
						Text(providerName)
							.font(.headline)
							.textSelection(.enabled)
					}
				}

				// MARK: - Title
				if let title = embed.title {
					if let urlStr = embed.url, let url = URL(string: urlStr) {
						Link(destination: url) {
							Text(markdown: title)
								.font(.title3)
								.multilineTextAlignment(.leading)
						}
					} else {
						Text(markdown: title)
							.font(.title3)
							.multilineTextAlignment(.leading)
					}
				}

				// MARK: - Description
				if let description = embed.description {
					Text(markdown: description)
						.textSelection(.enabled)
						.opacity(0.9)
						.frame(maxWidth: .infinity, alignment: .leading)
				}

				// MARK: - Fields
				if let fields = embed.fields {
					let grouped_fields = groupFields(_fields: fields)

					ForEach(0 ..< grouped_fields.count, id: \.self) { group_index in
						HStack(alignment: .top, spacing: 5) {
							ForEach(grouped_fields[group_index]) { field in
								VStack(alignment: .leading, spacing: 2) {
									Text(field.name)
										.font(.headline)
										.textSelection(.enabled)
									Text(markdown: field.value).opacity(0.9)
										.textSelection(.enabled)
										.frame(maxWidth: .infinity, alignment: .leading)
								}
							}
						}
					}
				}

				// MARK: - Image
				if let image = embed.image {
					embedMedia(image: image)
				}
				// MARK: Thumbnail
				if let thumb = embed.thumbnail {
					embedMedia(image: thumb)
				}

				// MARK: - Footer
				if let footer = embed.footer {
					HStack {
						if let iconURL = footer.icon_url {
							let width = 20.0
							let height = 20.0
							CachedAsyncImage(url: URL(string: iconURL)) { phase in
								if let image = phase.image {
									image.resizable().scaledToFill()
								} else {
									Spacer().frame(width: width, height: height)
								}
							}
							.frame(width: width, height: height)
							.cornerRadius(10)
						}

						Text(footer.text)
							.font(.system(size: 12, weight: .semibold))
							.textSelection(.enabled)

						if let timestamp = embed.timestamp {
							Text("•")
								.font(.title3)
								.font(.system(size: 12, weight: .semibold))
								.textSelection(.enabled)

							Text(timestamp, style: .date)
								.font(.system(size: 12, weight: .semibold))
								.textSelection(.enabled)
						}
					}
				}
			}
			.frame(maxWidth: mediaWidth != nil ? CGFloat(min(400, mediaWidth!)) : nil)
			.padding(10)
		}
		.background(
			HStack {
				if let col = embed.color {
					// Man, what a hack
					ZStack {
						Capsule()
							.fill(Color(hex: col))
							.frame(minWidth: 8, maxWidth: 8, maxHeight: .infinity)
							.offset(x: 2)
					}
					.frame(maxWidth: 4, maxHeight: .infinity)
					.clipped()
					Spacer()
				}
			}.drawingGroup()
		)
		.frame(minWidth: 400, maxWidth: 520, alignment: .leading)
		.onAppear {
			// print(embed)
		}
	}
}

struct EmbedView: View {
	let embed: Embed

	var body: some View {
		// TODO: Move away from embed.type, might be depreciated soon
		if embed.type == .gifVid {
			Text("Rendering GIF-as-a-video isn't supported yet")
		} else {
			RichEmbedView(embed: embed)
		}
	}
}

struct EmbedView_Previews: PreviewProvider {
	static var previews: some View {
		Text("test")
	}
}
