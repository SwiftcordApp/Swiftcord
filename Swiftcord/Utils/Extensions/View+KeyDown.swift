//
//  View+KeyDown.swift
//  Swiftcord
//
//  Created by ErrorErrorError on 2/2/23.
//  
//

import SwiftUI
import Foundation

extension View {
	func onKeyDown(callback: @escaping (KeyAwareView.Key) -> Void) -> some View {
		self.modifier(OnKeyDownModifier(callback: callback))
	}
}

struct OnKeyDownModifier: ViewModifier {
	let callback: (KeyAwareView.Key) -> Void
	func body(content: Content) -> some View {
		content.background(KeyAwareView(callback: callback))
	}
}

struct KeyAwareView: NSViewRepresentable {
	let callback: (Self.Key) -> Void

	func makeNSView(context: Context) -> KeyView {
		.init(callback)
	}

	func updateNSView(_ nsView: NSViewType, context: Context) {}

	enum Key {
		case `return`
	}
}

class KeyView: NSView {
	let callback: (KeyAwareView.Key) -> Void

	init(_ callback: @escaping (KeyAwareView.Key) -> Void) {
		self.callback = callback
		super.init(frame: .zero)
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
			self.keyDown(with: aEvent)
			return aEvent
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func keyDown(with event: NSEvent) {
		let keyCode = Int(event.keyCode)

		switch keyCode {
		case 0x24:
			if event.modifierFlags.rawValue == 0x100 {
				callback(.return)
			}
		default:
			break
		}
	}
}
