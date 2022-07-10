//
//  AnyTransition+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 16/6/22.
//

import SwiftUI

extension AnyTransition {
	// From https://stackoverflow.com/a/69696690/
	static var backslide: AnyTransition {
		.asymmetric(
			insertion: .move(edge: .trailing),
			removal: .move(edge: .leading)
		)
	}

	static var customOpacity: AnyTransition {
		.opacity.animation(.easeInOut(duration: 0.25))
	}
}
