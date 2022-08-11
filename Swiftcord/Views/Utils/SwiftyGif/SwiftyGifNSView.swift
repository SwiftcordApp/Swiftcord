//
//  SwiftyGifNSView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/7/22.
//

import SwiftUI
import SwiftyGif

final class SwiftyGifNSView: NSView {
	let imageView: NSImageView

	init(url: URL, width: Double? = nil, height: Double? = nil) {
		imageView = NSImageView(gifURL: url)
		super.init(frame: .zero)

		addSubview(imageView)
	}

	override func layout() {
		super.layout()
		imageView.frame = bounds
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
