//
//  ISOTimestamp+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation
import DiscordKit

extension ISOTimestamp {
	func toDate(hasFractionalSeconds: Bool = true) -> Date? {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        isoDateFormatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withDashSeparatorInDate
		]
		if hasFractionalSeconds { isoDateFormatter.formatOptions.update(with: .withFractionalSeconds) }
		if let date = isoDateFormatter.date(from: self) {
			return date
		} else {
			return hasFractionalSeconds ? nil : self.toDate(hasFractionalSeconds: true)
		}
    }
}
