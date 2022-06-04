//
//  AnalyticsWrapper.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 4/6/22.
//

import Foundation
import AppCenterAnalytics

// This could have been an extension to AppCenterAnalytics,
// but in the future this might be expanded to possibly send
// events to Discord too (for better client spoofing).
struct AnalyticsWrapper {
	enum EventType: String {
		case openPopout = "open_popout"
		case channelOpened = "channel_opened"
		case guildViewed = "guild_viewed"
		case DMListViewed = "dm_list_viewed"
		case settingsPaneViewed = "settings_pane_viewed"
	}

	static private func getBaseProps() -> [String: Any] {
		return [
			"cpu_core_count": ProcessInfo().processorCount
			// More entries will be added in the future
		]
	}

	static func event(type: EventType, properties: [String: Any]) {
		let combinedProps = getBaseProps().merging(properties) { $1 }

		let typedProps = EventProperties()
		for (prop, val) in combinedProps {
			if let stringVal = val as? String {
				typedProps.setEventProperty(stringVal, forKey: prop)
			} else if let doubleVal = val as? Double {
				typedProps.setEventProperty(doubleVal, forKey: prop)
			} else if let intVal = val as? Int {
				typedProps.setEventProperty(Int64(intVal), forKey: prop)
			} else if let boolVal = val as? Bool {
				typedProps.setEventProperty(boolVal, forKey: prop)
			} else if let dateVal = val as? Date {
				typedProps.setEventProperty(dateVal, forKey: prop)
			} else {
				typedProps.setEventProperty(String(describing: val), forKey: prop)
			}
		}
		Analytics.trackEvent(type.rawValue, withProperties: typedProps)
	}
}
