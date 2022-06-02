//
//  Date+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation


extension Date {
	func isSameDay(as date: Date) -> Bool {
		let com1 = Calendar.current.dateComponents([.year, .month, .day], from: self)
		let com2 = Calendar.current.dateComponents([.year, .month, .day], from: date)
		return com1.year == com2.year && com1.month == com2.month && com1.day == com2.day
	}
}
