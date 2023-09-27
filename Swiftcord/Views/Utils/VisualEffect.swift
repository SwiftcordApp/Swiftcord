//
//  VisualEffect.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/9/23.
//

import SwiftUI

struct VisualEffect: NSViewRepresentable {


	func updateNSView(_ nsView: NSView, context: Context) {
	}
	
	func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
}
