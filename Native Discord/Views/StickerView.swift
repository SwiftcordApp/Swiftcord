//
//  StickerView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import Lottie

struct StickerLoadingView: View {
    let size: Double
    var body: some View {
        ZStack {
            Image(systemName: "square.dashed")
                .font(.system(size: size - 10))
                .opacity(0.5)
            ProgressView()
                .progressViewStyle(.circular)
        }.frame(width: size, height: size)
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
    @State private var animation: Lottie.Animation? = nil
    @Binding var play: Bool
    
    var body: some View {
        ZStack {
            if !error { switch sticker.format_type {
            case .png:
                // Literally a walk in the park compared to lottie
                AsyncImage(url: URL(string: "\(apiConfig.cdnURL)stickers/\(sticker.id).png")!) { phase in
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
                            url: URL(string: "\(apiConfig.cdnURL)stickers/\(sticker.id).json")!,
                            closure: { anim in
                                guard anim != nil else {
                                    error = true
                                    return
                                }
                                animation = anim
                            },
                            animationCache: nil
                        )
                    }
                }
                else {
                    LottieView(
                        animation: animation!,
                        play: $play,
                        width: size,
                        height: size
                    ).lottieLoopMode(.loop).frame(width: size, height: size)
                }
            default: StickerErrorView(size: size)
            }}
            else { StickerErrorView(size: size) } // if error
        }
    }
}

struct StickerView: View {
    let sticker: StickerItem
    @State private var play = false
    @State private var infoShow = false
    @State private var error = false
    @State private var fullSticker: Sticker? = nil
    
    var body: some View {
        StickerItemView(sticker: sticker, size: 160, play: $play)
        .popover(isPresented: $infoShow, arrowEdge: .trailing) {
            VStack(alignment: .leading, spacing: 14) {
                if fullSticker != nil {
                    StickerItemView(sticker: sticker, size: 240, play: .constant(true))
                    Divider()
                    Text(fullSticker!.name).font(.title2).fontWeight(.bold)
                    Text(fullSticker!.description ?? "").padding(.top, -8)
                    if fullSticker!.pack_id != nil {
                        Button(action: {}) {
                            Label("View Sticker Pack", systemImage: "square.on.square")
                                .frame(maxWidth: .infinity)
                        }
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                    }
                }
                else {
                    Text("Loading sticker...").font(.headline)
                    ProgressView()
                        .progressViewStyle(.linear)
                        .frame(width: 240)
                }
            }.padding(14)
        }
        .onHover { h in play = h }
        .onTapGesture {
            if fullSticker == nil { Task {
                fullSticker = await DiscordAPI.getSticker(id: sticker.id)
            }}
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
