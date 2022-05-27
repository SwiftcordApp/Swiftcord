//
//  Double+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 11/5/22.
//

import Foundation
import AVFoundation

extension Double {
    // If the number is NaN or Infinite numbers, returns 0
    func fixNumbers() -> Double {
        self.isNaN || self.isInfinite ? 0 : self
    }

    // Format seconds to ss:mm(:hh)
    func humanReadableTime() -> String {
        let hour = Int(self / 60 / 60),
            min = Int(self.truncatingRemainder(dividingBy: 60*60) / 60),
            sec = Int(self.truncatingRemainder(dividingBy: 60*60).truncatingRemainder(dividingBy: 60))
        return hour > 0
			? String(format: "%02d:%02d:%02d", hour, min, sec)
			: String(format: "%02d:%02d", min, sec)
    }
}
