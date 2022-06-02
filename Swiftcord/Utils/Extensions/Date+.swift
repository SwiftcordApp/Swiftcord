//
//  Date+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation

extension Date {
	func isSameDay(as date: Date) -> Bool {
		let diff = Calendar.current.dateComponents([.day], from: self, to: date)
		return diff.day == 0
	}
}
