//
//  BetterImageView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 8/8/22.
//

import SwiftUI
import CachedAsyncImage

/// A much better base for remote images, has loading placeholders built in and sane default modifiers for the image
struct BetterImageView: View {
	let url: URL?

    var body: some View {
		CachedAsyncImage(url: url) { phase in
			if let image = phase.image {
				image
					.resizable()
					.scaledToFill()
					.transition(.customOpacity)
			} else {
				Rectangle().fill(.gray.opacity(0.25)).transition(.customOpacity)
			}
		}
    }
}
