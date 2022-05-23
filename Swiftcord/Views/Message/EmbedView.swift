//
//  EmbedView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/2/22.
//

import SwiftUI
import CachedAsyncImage
import DiscordKit

struct EmbedView: View {
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
	
	var body: some View {
		GroupBox {
			VStack(alignment: .leading, spacing: 8) {
				if let author = embed.author {
					HStack (alignment: .center, spacing: 8) {
						if let icon_url = author.icon_url {
							let width = 24.0
							let height = 24.0
							CachedAsyncImage(url: URL(string: icon_url)) { phase in
								if let image = phase.image { image.resizable().scaledToFill() }
								else {
									Spacer()
										.frame(width: width, height: height)
								}
							}
							.frame(
								width: width,
								height: height
							)
							.cornerRadius(12)
						}

						if let author_name = author.name {
							Text(.init(author.url != nil ? "[\(author_name)](\(author.url ?? ""))"
									   : author_name))
								.font(.title3)
								.underline(true, color: .clear)
								.textSelection(.enabled)
								.foregroundColor(.white)
						}
					}
				}

				if let title = embed.title {
					Text(.init(embed.url != nil ? "[\(title)](\(embed.url ?? ""))" : title))
						 .font(.title3)
						 .textSelection(.enabled)
				}

				if let description = embed.description {
					Text(.init(description))
						.textSelection(.enabled)
						.opacity(0.9)
						.frame(maxWidth: .infinity, alignment: .leading)
				}

				if let fields = embed.fields {
					let grouped_fields = groupFields(_fields: fields)

					ForEach (0 ..< grouped_fields.count, id: \.self) { group_index in
						HStack (alignment: .top, spacing: 5) {
							ForEach(grouped_fields[group_index]) { field in
								VStack(alignment: .leading, spacing: 2) {
									Text(field.name)
										.font(.headline)
										.textSelection(.enabled)
									Text(.init(field.value)).opacity(0.9)
										.textSelection(.enabled)
										.frame(maxWidth: .infinity, alignment: .leading)
								}
							}
						}
					}
				}

				if let image = embed.image {
					let width = Double(image.width != nil ? min(384, image.width!) : 384)
					let height = (image.width != nil && image.height != nil)
						? width / (Double(image.width!) / Double(image.height!))
						: 216
					CachedAsyncImage(url: URL(string: image.url)!) { phase in
						if let image = phase.image {
							image.resizable().scaledToFill()
						} else if phase.error != nil {

						} else {
							ProgressView()
								.progressViewStyle(.circular)
								.frame(width: width, height: height)
						}
					}
					.frame(width: width, height: height)
					.cornerRadius(4)
				}
				
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
							
							Text(timestamp.toDate(hasFractionalSeconds: false)?.toDateString() ?? "")
								.font(.system(size: 12, weight: .semibold))
								.textSelection(.enabled)
						}
					}
				}
			}.padding(10)
		}
		.overlay(
			HStack {
				// Man, what a hack
				ZStack {
					Capsule()
						.fill(embed.color != nil ? Color(hex: embed.color!) : Color.accentColor)
						.frame(minWidth: 8, maxWidth: 8, maxHeight: .infinity)
						.offset(x: 2)
				}
				.frame(maxWidth: 4, maxHeight: .infinity)
				.clipped()
				Spacer()
			}
		)
		.frame(minWidth: 400, maxWidth: 520, alignment: .leading)
	}
}

struct EmbedView_Previews: PreviewProvider {
	static var previews: some View {
		EmptyView()
	}
}
