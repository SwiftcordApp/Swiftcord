//
//  HelperInstances.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 26/10/22.
//

import Foundation

/// Static instances of some helper classes such as date formatters
struct HelperInstances {
	private(set) static var intervalFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.maximumUnitCount = 1
		formatter.unitsStyle = .full
		formatter.includesApproximationPhrase = true
		formatter.allowedUnits = [.hour, .minute, .second]

		/* Legacy code - more accurate but doesn't localise well
		if difference < 60 { // Less than a minute
		    lasted = "a few seconds"
		} else {
			let minutes = round(difference / 60)
			if (minutes < 3) { // less than 3 minutes
				lasted = "a few minutes"
			} else if (minutes < 60) { // less than 1 hour
				lasted = "\(String(format: "%.0f", minutes)) minutes"
			} else if(minutes < 120) { // less than 2 hours
				lasted = "an hour"
			} else {
				lasted = "\(String(format: "%.0f", round(minutes/60))) hours"
			}
		}
		*/

		return formatter
	}()
}
