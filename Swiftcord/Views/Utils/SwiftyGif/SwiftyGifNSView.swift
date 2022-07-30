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
	let width: Double?
	let height: Double?

	init(url: URL, width: Double? = nil, height: Double? = nil) {
		imageView = NSImageView(gifURL: url)
		imageView.translatesAutoresizingMaskIntoConstraints = false

		self.width = width
		self.height = height
		super.init(frame: .zero)

		addSubview(imageView)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewWillDraw() {
		super.viewWillDraw()

		if let width = width, let height = height {
			NSLayoutConstraint.activate([
				imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
				imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
				imageView.heightAnchor.constraint(equalToConstant: height),
				imageView.widthAnchor.constraint(equalToConstant: width)
			])
		} else {
			NSLayoutConstraint.activate([
				imageView.topAnchor.constraint(equalTo: topAnchor),
				imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
				imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
				imageView.leadingAnchor.constraint(equalTo: leadingAnchor)
			])
		}
	}
}
