//
//  StickerView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import Lottie

struct StickerView: View {
    let sticker: StickerItem
    @State private var animation: Lottie.Animation? = nil
    @State private var play = false
    
    var body: some View {
        ZStack { switch sticker.format_type { // Wrapper ZStack to catch events
        case .png:
            // Literally a walk in the park compared to lottie
            AsyncImage(url: URL(string: "\(apiConfig.cdnURL)stickers/\(sticker.id).png")!) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView().progressViewStyle(.circular)
            }.frame(width: 160, height: 160).clipShape(RoundedRectangle(cornerRadius: 7))
        case .lottie:
            if animation == nil {
                ZStack {
                    Image(systemName: "square").font(.system(size: 150))
                    ProgressView()
                        .progressViewStyle(.circular)
                        .onAppear {
                            Lottie.Animation.loadedFrom(
                                url: URL(string: "\(apiConfig.cdnURL)stickers/\(sticker.id).json")!,
                                closure: { anim in
                                    guard anim != nil else {
                                        print("Sticker loading error")
                                        return
                                    }
                                    animation = anim
                                },
                                animationCache: nil
                            )
                        }
                }
                .frame(width: 160, height: 160)
            }
            else {
                LottieView(
                    animation: animation!,
                    play: $play,
                    width: 160,
                    height: 160
                ).lottieLoopMode(.loop).frame(width: 160, height: 160)
            }
        default: EmptyView()
        }}.onHover { h in play = h }
    }
}

struct StickerView_Previews: PreviewProvider {
    static var previews: some View {
        // StickerView()
        EmptyView()
    }
}
