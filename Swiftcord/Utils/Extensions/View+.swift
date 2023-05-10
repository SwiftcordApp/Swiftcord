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

	@ViewBuilder func zeroRowInsets() -> some View {
		self.listRowInsets(.init())
	}
}

extension View {
	func heightReader(_ binding: Binding<CGFloat>) -> some View {
		self.overlay {
			GeometryReader { geometry -> Color in
				let rect = geometry.frame(in: .local)
				DispatchQueue.main.async {
					binding.wrappedValue = rect.size.height
				}
				return .clear
			}
		}
	}
}

extension View {
	func removeSidebarToggle(windowModifier: @escaping (NSWindow) -> Void = { _ in }) -> some View {
		modifier(RemoveSidebarToggleModifier(windowModifier: windowModifier))
	}
}

private struct RemoveSidebarToggleModifier: ViewModifier {
	let windowModifier: (NSWindow) -> Void

	func body(content: Content) -> some View {
		content.task {
			guard let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "com_apple_SwiftUI_Settings_window" }) else { return }
			windowModifier(window)
			let sidebaritem = "com.apple.SwiftUI.navigationSplitView.toggleSidebar"
			if let index = window.toolbar?.items.firstIndex(where: { $0.itemIdentifier.rawValue == sidebaritem }) {
				window.toolbar?.removeItem(at: index)
			}
		}
	}
}
