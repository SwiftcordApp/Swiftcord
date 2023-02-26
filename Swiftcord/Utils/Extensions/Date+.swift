//
//  Date+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation

extension Date {
	func isSameDay(as date: Date) -> Bool {
		Calendar.current.isDate(self, inSameDayAs: date)
	}
}
