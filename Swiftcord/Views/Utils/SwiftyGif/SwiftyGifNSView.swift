//
//  SwiftyGifNSView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/7/22.
//

import SwiftUI
import SwiftyGif

final class SwiftyGifNSView: NSView {
	fileprivate var _animate = true

	private let imageView: NSImageView

	var isAnimating: Bool {
		get { _animate }
		set {
			_animate = newValue
			if newValue {
				imageView.startAnimatingGif()
			} else {
				imageView.stopAnimatingGif()
			}
		}
	}
	var currentFrame: Int {
		get { imageView.currentFrameIndex() }
		set { imageView.showFrameAtIndex(newValue) }
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(url: URL, width: Double? = nil, height: Double? = nil) {
		imageView = NSImageView()
		imageView.setGifFromURL(url, levelOfIntegrity: .highestNoFrameSkipping)

		super.init(frame: .zero)
		imageView.delegate = self

		addSubview(imageView)
	}

	override func layout() {
		super.layout()
		imageView.frame = bounds
	}
}

extension SwiftyGifNSView: SwiftyGifDelegate {
	func gifDidStart(sender: NSImageView) {
		// Ensure the real animating state never desyncs from the required state
		if !_animate {
			isAnimating = false
		} else {
			_animate = true // Update underlying var
		}
	}
	func gifDidStop(sender: NSImageView) {
		if _animate {
			isAnimating = true
		} else {
			_animate = false // Update underlying var
		}
	}
}
