//
//  SubtractDates.swift
//  Native Discord
//
//  Created by Vincent Kwok on 25/2/22.
//

import Foundation

extension Date {
    static func - (d1: Date, d2: Date) -> TimeInterval {
        return d1.timeIntervalSinceReferenceDate - d2.timeIntervalSinceReferenceDate
    }
}
