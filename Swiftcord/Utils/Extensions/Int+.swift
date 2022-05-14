//
//  Int+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 7/3/22.
//

import Foundation

extension Int {
    /// Takes a dict of bit positions to flags
    /// and returns an array of flags where the
    /// corrosponding bit in the Int is true
    func decodeFlags<T: RawRepresentable & CaseIterable>(flags: T) -> [T] where T.RawValue == Int {
        var a: [T] = []
        T.allCases.forEach { c in
            if (self & (1 << c.rawValue)) != 0 { a.append(c) }
        }
        return a
    }
}

extension Int {
	func humanReadableFileSize() -> String {
		guard self > 0 else {
			return "0 bytes"
		}

		// Adapted from http://stackoverflow.com/a/18650828
		let suffixes = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
		let k: Double = 1000
		let i = floor(log(Double(self)) / log(k))

		// Format number with thousands separator and everything below 1 GB with no decimal places.
		let numberFormatter = NumberFormatter()
		numberFormatter.maximumFractionDigits = i < 3 ? 0 : 1
		numberFormatter.numberStyle = .decimal

		let numberString = numberFormatter.string(from: NSNumber(value: Double(self) / pow(k, i))) ?? "Unknown"
		let suffix = suffixes[Int(i)]
		return "\(numberString) \(suffix)"
	}
}
