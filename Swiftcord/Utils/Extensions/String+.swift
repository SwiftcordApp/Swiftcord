//
//  String+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import Foundation

// From: https://stackoverflow.com/a/39425959
extension Character {
	/// A simple emoji is one scalar and presented to the user as an Emoji
	var isSimpleEmoji: Bool {
		guard let firstScalar = unicodeScalars.first else { return false }
		return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
	}

	/// Checks if the scalars will be merged into an emoji
	var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

	var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }

	var isReturn: Bool { asciiValue == 0x0A }
}

extension String {
	var isSingleEmoji: Bool { count == 1 && containsEmoji }
	
	var containsEmoji: Bool { contains { $0.isEmoji } }
	
	var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
	
	var containsOnlyEmojiAndSpaces: Bool {
		replacingOccurrences(of: " ", with: "").containsOnlyEmoji
	}
	
	var emojiString: String { emojis.map { String($0) }.reduce("", +) }
	
	var emojis: [Character] { filter { $0.isEmoji } }
	
	var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}

extension String {
	var fileExtension: String {
		NSString(string: self).pathExtension
	}
}

extension String {
	/// Returns true if the string has any content after stripping spaces/newlines
	func hasContent() -> Bool {
		let text = self.trimmingCharacters(in: .whitespacesAndNewlines)
		return !text.isEmpty
	}
}

extension String {
	
	/// Returns an array of `Range<Index>` representing the ranges of the given `substring` within the `String`.
	///
	/// - Parameter substring: The substring to search for within the `String`.
	/// - Returns: An array of `Range<Index>` representing the ranges of the given `substring` within the `String`.
	func ranges(of substring: String) -> [Range<Index>] {
		var ranges: [Range<Index>] = []
		var start = self.startIndex
		
		while let range = self[start..<endIndex].range(of: substring) {
			// Add the range of the current match to the list of ranges
			ranges.append(range.lowerBound..<range.upperBound)
			
			// Move the start index to just past the end of the current match
			start = range.upperBound
		}
		return ranges
	}
}
