//
//  GifView.swift
//  Swiftcord
//
//  Created by Andrew Glaze on 7/8/22.
//

import AppKit
import SwiftUI
import SwiftyGif

struct GifView: NSViewRepresentable {

	private var url: URL
	private var size: Int
	
	public init(_ url: URL, size: Int) {
		self.url = url
		self.size = size
	}
	
	public func updateNSView(_ nsView: NSImageView, context: Context) {
		
	}
	
	public func makeNSView(context: Context) -> NSImageView {
		let imageView = NSImageView()
		let resizeURL = URL(string: url.absoluteString + "?size=\(size)")!
//		let loader = NSView(frame: .init(x: 0, y: 0, width: size, height: size))
//		loader.layer?.backgroundColor = Color.gray.opacity(Double.random(in: 0.15...0.3)).cgColor
//		loader.layer?.cornerRadius = 12
		imageView.setGifFromURL(resizeURL)
		return imageView
	}
	
	
}
