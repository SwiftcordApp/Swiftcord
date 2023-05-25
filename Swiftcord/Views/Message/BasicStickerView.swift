//
//  BasicStickerView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//
import SwiftUI
import Lottie
import CachedAsyncImage
import DiscordKitCore
import DiscordKit

struct StickerLoadingView: View {
	let size: Double
	var body: some View {
		RoundedRectangle(cornerRadius: 12)
			.fill(.gray.opacity(Double.random(in: 0.15...0.3)))
			.frame(width: size, height: size)
	}
}

struct StickerErrorView: View {
	let size: Double
	var body: some View {
		Image(systemName: "square.slash")
			.font(.system(size: size - 10))
			.opacity(0.5)
			.frame(width: size, height: size)
	}
}

enum StickerPlayCondition {
	case always
	case onHover
	case useDefault
}

// Most basic sticker player
struct StickerItemView: View {
	let sticker: StickerItem
	let size: Double // Width and height of sticker
	let play: StickerPlayCondition
	@State private var error = false
	@State private var animation: Lottie.LottieAnimation?
	@State private var hovered = false
	@AppStorage("stickerAlwaysAnim") private var alwaysAnimStickers = true
	private func playAnimation(value: Bool) {
		// Without this check, the sticker animation restarts if it's hovered
		if (play == .useDefault && !alwaysAnimStickers) || play == .onHover {
			hovered = value
		}
	}

	var body: some View {
		if error {
			StickerErrorView(size: size)
		} else {
			switch sticker.format_type {
			case .png:
				// Literally a walk in the park compared to lottie
				AsyncImage(url: URL(string: "\(DiscordKitConfig.default.cdnURL)stickers/\(sticker.id).png")!) { phase in
					switch phase {
					case .empty: StickerLoadingView(size: size)
					case .success(let image): image.resizable().scaledToFill()
					case .failure: StickerErrorView(size: size)
					default: StickerErrorView(size: size)
					}
				}
				.frame(width: size, height: size)
				.clipShape(RoundedRectangle(cornerRadius: 7))
			case .lottie:
				if animation == nil {
					StickerLoadingView(size: size).onAppear {
						Lottie.LottieAnimation.loadedFrom(
							url: URL(string: "\(DiscordKitConfig.default.cdnURL)stickers/\(sticker.id).json")!,
							closure: { anim in
								guard let anim = anim else {
									error = true
									return
								}
								animation = anim
							},
							animationCache: Lottie.DefaultAnimationCache.sharedCache
						)
					}.transition(.customOpacity)
				} else {
					LottieView(
						animation: animation!,
						play: .constant(play == .always || (play == .useDefault && alwaysAnimStickers) || hovered),
						width: size,
						height: size
					)
					.lottieLoopMode(.loop)
					.frame(width: size, height: size)
					.transition(.customOpacity)
					.onHover(perform: playAnimation)
				}
			default:
				// Well it doesn't animate for some reason
				CachedAsyncImage(url: URL(string: "\(DiscordKitConfig.default.cdnURL)stickers/\(sticker.id).png?passthrough=true")!) { phase in
					switch phase {
					case .empty: StickerLoadingView(size: size)
					case .success(let image): image.resizable().scaledToFill()
					case .failure: StickerErrorView(size: size)
					default: StickerErrorView(size: size)
					}
				}
				.frame(width: size, height: size)
				.clipShape(RoundedRectangle(cornerRadius: 7))
			}
		}
	}
}
