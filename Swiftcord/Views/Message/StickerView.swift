//
//  StickerView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import Lottie
import DiscordKitCommon
import CachedAsyncImage
import DiscordKitCore

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

// Most basic sticker player
struct StickerItemView: View {
    let sticker: StickerItem
    let size: Double // Width and height of sticker
    @State private var error = false
    @State private var animation: Lottie.Animation?
    @Binding var play: Bool

    var body: some View {
		if error {
			StickerErrorView(size: size)
		} else {
			switch sticker.format_type {
			case .png:
				// Literally a walk in the park compared to lottie
				AsyncImage(url: URL(string: "\(GatewayConfig.default.cdnURL)stickers/\(sticker.id).png")!) { phase in
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
						Lottie.Animation.loadedFrom(
							url: URL(string: "\(GatewayConfig.default.cdnURL)stickers/\(sticker.id).json")!,
							closure: { anim in
								guard let anim = anim else {
									error = true
									return
								}
								animation = anim
							},
							animationCache: Lottie.LRUAnimationCache.sharedCache
						)
					}.transition(.customOpacity)
				} else {
					LottieView(
						animation: animation!,
						play: $play,
						width: size,
						height: size
					)
					.lottieLoopMode(.loop)
					.frame(width: size, height: size)
					.transition(.customOpacity)
				}
			default:
				// Well it doesn't animate for some reason
				CachedAsyncImage(url: URL(string: "\(GatewayConfig.default.cdnURL)stickers/\(sticker.id).png?passthrough=true")!) { phase in
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

struct StickerView: View {
    let sticker: StickerItem
    @State private var hovered = false
    @State private var infoShow = false
    @State private var error = false
    @State private var fullSticker: Sticker?
    @State private var packPresenting = false

	@EnvironmentObject var restAPI: DiscordREST

	@AppStorage("stickerAlwaysAnim") private var alwaysAnimStickers = true

	private func openPopoverEvt() {
		AnalyticsWrapper.event(type: .openPopout, properties: [
			"type": "Sticker Popout",
			"sticker_pack_id": fullSticker?.pack_id ?? "",
			"sticker_id": fullSticker?.id ?? ""
		])
	}

    var body: some View {
		StickerItemView(sticker: sticker, size: 160, play: .constant(alwaysAnimStickers || hovered))
        .popover(isPresented: $infoShow, arrowEdge: .trailing) {
            VStack(alignment: .leading, spacing: 14) {
                if let fullSticker = fullSticker {
                    StickerItemView(sticker: sticker, size: 240, play: .constant(true))
                    Divider()
                    Text(fullSticker.name).font(.title2).fontWeight(.bold)
                    if let description = fullSticker.description {
                        Text(description).padding(.top, -8)
                    }
                    if sticker.format_type == .aPNG {
                        Text("Sorry, aPNG stickers can't be played (yet)").font(.footnote)
                    }

                    if fullSticker.pack_id != nil {
                        Button(action: { packPresenting = true }) {
                            Label("View Sticker Pack", systemImage: "square.on.square")
                                .frame(maxWidth: .infinity)
                        }
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .sheet(isPresented: $packPresenting, content: {
                            VStack {
                                Text("Sticker Pack").font(.title)
                                Text("Unimplemented").font(.footnote)
                                Button { packPresenting = false } label: {
                                    Text("Close")
                                }
                            }.padding(14)
                        })
                    }
                } else {
                    Text("Loading sticker...").font(.headline)
                    ProgressView()
                        .progressViewStyle(.linear)
                        .frame(width: 240)
						.tint(.blue)
                }
            }.padding(14)
        }
        .onHover { hovered = $0 }
        .onTapGesture {
            if fullSticker == nil { Task {
                fullSticker = await restAPI.getSticker(id: sticker.id)
				openPopoverEvt()
			}} else {
				openPopoverEvt()
			}
            infoShow.toggle()
        }
    }
}

struct StickerView_Previews: PreviewProvider {
    static var previews: some View {
        // StickerView()
        EmptyView()
    }
}
