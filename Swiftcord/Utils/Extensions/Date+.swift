//
//  Date+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation

// DateFormatters are heavy, so just cache one here
// There's probably a better way to do this lol
let commonDateFormatter = DateFormatter()

extension Date {
	func toTimeString(with fmt: String = "hh:mm a") -> String {
		commonDateFormatter.setLocalizedDateFormatFromTemplate(fmt)
        return commonDateFormatter.string(from: self)
    }

	func toDateString(with fmt: String = "dd/MM/yy") -> String {
		commonDateFormatter.setLocalizedDateFormatFromTemplate(fmt)
        return commonDateFormatter.string(from: self)
    }
	func toDateString(with style: DateFormatter.Style) -> String {
		commonDateFormatter.dateStyle = style
		return commonDateFormatter.string(from: self)
	}
}

extension Date {
	static func - (lhs: Date, rhs: Date) -> TimeInterval {
		return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
	}
}

extension Date {
	func isSameDay(as date: Date) -> Bool {
		let com1 = Calendar.current.dateComponents([.year, .month, .day], from: self)
		let com2 = Calendar.current.dateComponents([.year, .month, .day], from: date)
		return com1.year == com2.year && com1.month == com2.month && com1.day == com2.day
	}
}
