//
//  BetterImageView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 8/8/22.
//

import SwiftUI
import CachedAsyncImage

/// A much better base for remote images, has loading placeholders built in and sane default modifiers for the image
struct BetterImageView<ErrorContent: View>: View {
	let url: URL?
	@ViewBuilder let customErrorView: ErrorContent

    var body: some View {
		CachedAsyncImage(url: url) { phase in
			if let image = phase.image {
				image
					.resizable()
					.scaledToFill()
					.transition(.customOpacity)
			} else if phase.error != nil {
				customErrorView
			} else {
				Rectangle().fill(.gray.opacity(0.25)).transition(.customOpacity)
			}
		}
    }
}

extension BetterImageView where ErrorContent == EmptyView {
	init(url: URL?) {
		self.init(url: url) {
			EmptyView()
		}
	}
}
