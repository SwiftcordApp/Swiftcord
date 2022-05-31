//
//  ReversingOpacity.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 31/5/22.
//

import SwiftUI

// Adapted from https://stackoverflow.com/a/61017784/
struct ReversingOpacity: AnimatableModifier {
	var value: Double

	private let target: Double
	private let onEnded: () -> Void
	private let endDelay: TimeInterval

	init(to value: Double, endDelay: TimeInterval = 0, onEnded: @escaping () -> Void = {}) {
		target = value
		self.value = value
		self.onEnded = onEnded // << callback
		self.endDelay = endDelay
	}

	var animatableData: CGFloat {
		get { value }
		set { value = newValue
			// newValue is interpolating by engine, so changing from
			// previous to initially set, so when they are equal, the
			// animation has ended
			let callback = onEnded
			if newValue == target, newValue != 0 {
				DispatchQueue.main.asyncAfter(deadline: .now() + endDelay, execute: callback)
			}
		}
	}

	func body(content: Content) -> some View {
		content.opacity(value)
	}
}
