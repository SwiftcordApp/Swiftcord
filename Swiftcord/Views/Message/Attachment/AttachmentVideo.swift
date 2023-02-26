//
//  AttachmentVideo.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 3/8/22.
//

import SwiftUI
import AVKit

struct AttachmentVideo: View {
	let width: Double
	let height: Double
	let scale: Double
	let url: URL
	let thumbnailURL: URL

	@State private var player: AVPlayer?

	var body: some View {
		if let player = player {
			VideoPlayer(player: player)
				.frame(width: CGFloat(width), height: CGFloat(height))
				.cornerRadius(8)
		} else {
			ZStack {
				AttachmentImage(
					width: width,
					height: height,
					scale: scale,
					url: thumbnailURL
				)
				Button {
					player = AVPlayer(url: url) // Don't use resizedURL
					player?.play()
				} label: {
					Image(systemName: "play.fill")
						.font(.system(size: 28))
						.frame(width: 56, height: 56)
						.background(.thickMaterial)
						.clipShape(Circle())
				}.buttonStyle(.borderless)
			}
		}
	}
}
