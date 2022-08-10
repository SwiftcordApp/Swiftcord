//
//  SwiftyGifView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/7/22.
//

import SwiftUI

struct SwiftyGifView: NSViewRepresentable {
	let url: URL
	var animating = true
	var resetWhenNotAnimating = false

	func makeNSView(context: Context) -> SwiftyGifNSView {
		let view = SwiftyGifNSView(url: url)
		view.isAnimating = animating
		if !animating { view.currentFrame = 0 }
		return view
	}

	func updateNSView(_ view: SwiftyGifNSView, context: Context) {
		view.isAnimating = animating
		if resetWhenNotAnimating, !animating { view.currentFrame = 0 }
	}
}

#if DEBUG

struct MacEditorTextView_Previews: PreviewProvider {
	static var previews: some View {
		SwiftyGifView(url: URL(string: "https://c.tenor.com/0KEvxoQb5a4AAAAC/doubt-press-x.gif")!)
	}
}

#endif
