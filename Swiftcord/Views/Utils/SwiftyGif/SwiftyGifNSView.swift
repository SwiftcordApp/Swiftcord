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

	init(url: URL) {
		imageView = NSImageView(gifURL: url)
		imageView.translatesAutoresizingMaskIntoConstraints = false

		super.init(frame: .zero)

		addSubview(imageView)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewWillDraw() {
		super.viewWillDraw()

		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: topAnchor),
			imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
			imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
			imageView.leadingAnchor.constraint(equalTo: leadingAnchor)
		])
	}
}
