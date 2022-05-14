//
//  Date+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation

extension Date {
    func toTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm a")
        return dateFormatter.string(from: self)
    }
    
    func toDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM/yy")
        return dateFormatter.string(from: self)
    }
}

extension Date {
	static func - (d1: Date, d2: Date) -> TimeInterval {
		return d1.timeIntervalSinceReferenceDate - d2.timeIntervalSinceReferenceDate
	}
}
