//
//  MessageContentView.swift
//  Swiftcord
//
//  Created by Andrew Glaze on 7/8/22.
//

import SwiftUI
import WrappingStack
import SwiftyGif
import CachedAsyncImage
import DiscordKitCommon

struct MessageContentView: View {
	let content: [MessagePart]
	let serverCtx: ServerContext
	let emoteOnly: Bool
	
    var body: some View {
		WrappingHStack(id: \.self, alignment: .topLeading, horizontalSpacing: 0) {
			ForEach(content, id: \.self) { part in
				switch part {
				case .text(let s):
					Text(markdown: s)
						.font(.system(
							size: emoteOnly ? 48 : 15
						))
						.fixedSize(horizontal: false, vertical: true)
				case .emote(let url, emoteId: _, emoteName: _):
					CachedAsyncImage(url: url) { image in
						image
							.resizable()
							.scaledToFit()
					} placeholder: {
						RoundedRectangle(cornerRadius: 12)
							.fill(.gray.opacity(Double.random(in: 0.15...0.3)))
					}.frame(width: emoteOnly ? 48 : 15, height: emoteOnly ? 48 : 15, alignment: .center)
				case .aniEmote(let url, emoteId: _, emoteName: _):
//					CachedAsyncImage(url: url) { image in
//						image
//							.resizable()
//							.scaledToFit()
//					} placeholder: {
//						RoundedRectangle(cornerRadius: 12)
//							.fill(.gray.opacity(Double.random(in: 0.15...0.3)))
//					}.frame(width: emoteOnly ? 48 : 15, height: emoteOnly ? 48 : 15, alignment: .center)
					GifView(url, size: emoteOnly ? 48 : 15)
						.frame(width: emoteOnly ? 48 : 15, height: emoteOnly ? 48 : 15, alignment: .center)
				case .channel(let id):
					Text("#\(id)")
						.font(.system(
							size: emoteOnly ? 48 : 15
						))
				case .role(let id):
					Text("@\(id)")
						.font(.system(
							size: emoteOnly ? 48 : 15
						))
				case .user(let id):
					Text("@\(id)")
						.font(.system(
							size: emoteOnly ? 48 : 15
						))
				case .timestamp(let time, style: _):
					Text(time)
						.font(.system(
							size: emoteOnly ? 48 : 15
						))
				}
			}
		}
		.textSelection(.enabled)
    }
}

//struct MessageContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageContentView()
//    }
//}
