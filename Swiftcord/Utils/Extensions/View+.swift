//
//  View+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 16/3/22.
//

import Foundation
import SwiftUI

// From: https://www.avanderlee.com/swiftui/conditional-view-modifier/
extension View {
	/// Applies the given transform if the given condition evaluates to `true`.
	/// - Parameters:
	///   - condition: The condition to evaluate.
	///   - transform: The transform to apply to the source `View`.
	/// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
	@ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}

struct PointableModifier: ViewModifier {
	@Environment(\.isEnabled) var isEnabled

	func body(content: Content) -> some View {
		content.onHover { $0 && isEnabled ? NSCursor.pointingHand.push() : NSCursor.pop() }
	}
}

extension View {
	func pointable() -> some View {
		self.modifier(PointableModifier())
	}
}
