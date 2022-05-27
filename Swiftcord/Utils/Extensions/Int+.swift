//
//  Int+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 7/3/22.
//

import Foundation

extension Int {
	func humanReadableFileSize() -> String {
		guard self > 0 else {
			return "0 bytes"
		}

		// Adapted from http://stackoverflow.com/a/18650828
		let suffixes = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
		let base: Double = 1000
		let unitIdx = floor(log(Double(self)) / log(base))

		// Format number with thousands separator and everything below 1 GB with no decimal places.
		let numberFormatter = NumberFormatter()
		numberFormatter.maximumFractionDigits = unitIdx < 3 ? 0 : 1
		numberFormatter.numberStyle = .decimal

		let numberString = numberFormatter.string(
			from: NSNumber(value: Double(self) / pow(base, unitIdx))
		) ?? "Unknown"
		let suffix = suffixes[Int(unitIdx)]
		return "\(numberString) \(suffix)"
	}
}
