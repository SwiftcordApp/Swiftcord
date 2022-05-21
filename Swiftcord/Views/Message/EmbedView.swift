//
//  EmbedView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/2/22.
//

import SwiftUI
import CachedAsyncImage
import DiscordAPI

struct EmbedView: View {
	@State var embed: Embed
	
	var body: some View {
		GroupBox {
			VStack(alignment: .leading, spacing: 8) {
				EmbedAuthor(embed: $embed)
				
				EmbedTD(embed: $embed)
				
				EmbedFields(embed: $embed)
				
				EmbedImg(embed: $embed)
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

struct EmbedAuthor: View {
	@Binding var embed: Embed
	
	var body: some View {
		if let author = embed.author {
			HStack (alignment: .center, spacing: 8) {
				if let icon_url = author.icon_url {
					let width = 24.0
					let height = 24.0
					CachedAsyncImage(url: URL(string: icon_url)) { phase in
						if let image = phase.image {
							image.resizable().scaledToFill()
						} else {
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
					if let author_url = author.url {
						Text(.init("[" + author_name + "](" + author_url + ")"))
							.font(.headline)
							.textSelection(.enabled)
					} else {
						Text(author_name)
							.font(.headline)
							.textSelection(.enabled)
					}
				}
			}
		}
	}
}

struct EmbedTD: View {
	@Binding var embed: Embed
	var body: some View {
		if let title = embed.title {
			if let url = embed.url {
				Text(.init("[" + title + "](" + url + ")"))
					 .font(.title3)
					 .textSelection(.enabled)
			} else {
				Text(title)
					.font(.title3)
					.textSelection(.enabled)
			}
		}
		
		if let description = embed.description {
			Text(.init(description))
				.textSelection(.enabled)
				.opacity(0.9)
				.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
}

struct EmbedFields: View {
	@Binding var embed: Embed
	
	func getFields() {
		
	}
	var body: some View {
		if let fields = embed.fields {
			let f = fields.chunks(3)
			
			ForEach (f.indices, id: \.self) { fsi in
				let fs = f[fsi]
				HStack (alignment: .top, spacing: 5) {
					ForEach(fs) { field in
						VStack(alignment: .leading, spacing: 2) {
							Text(field.name)
								.font(.headline)
								.textSelection(.enabled)
							Text(field.value).opacity(0.9)
								.textSelection(.enabled)
								.frame(maxWidth: .infinity, alignment: .leading)
						}
					}
				}
			}
		}
	}
}

struct EmbedImg: View {
	@Binding var embed: Embed
	var body: some View {
		
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
			.frame(
				width: width,
				height: height
			)
			.cornerRadius(4)
		}
	}
}

struct EmbedView_Previews: PreviewProvider {
	static var previews: some View {
		EmptyView()
	}
}
