//
//  URL+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 31/7/22.
//

import Foundation

extension URL {
	var isAnimatable: Bool {
		lastPathComponent.prefix(2) == "a_"
	}

	func modifyingPathExtension(_ newExt: String) -> Self {
		deletingPathExtension().appendingPathExtension(newExt)
	}
}
