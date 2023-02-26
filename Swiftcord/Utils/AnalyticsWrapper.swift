//
//  AnalyticsWrapper.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 4/6/22.
//

import Foundation
import AppCenterAnalytics
import os

// This could have been an extension to AppCenterAnalytics,
// but in the future this might be expanded to possibly send
// events to Discord too (for better client spoofing).
struct AnalyticsWrapper {
	enum EventType: String {
		case openPopout = "open_popout"
		case openModal = "open_modal"
		case channelOpened = "channel_opened"
		case guildViewed = "guild_viewed"
		case DMListViewed = "dm_list_viewed"
		case settingsPaneViewed = "settings_pane_viewed"
		case analyticsEnabled = "analytics_enabled" // Seperate events for easier viewing in AppCenter
		case analyticsDisabled = "analytics_disabled"
		case inviteOpened = "invite_opened"
		case networkInviteResolve = "network_action_invite_resolve"
		case resolveInvite = "resolve_invite"
		case supporterCTAClick = "supporter_cta_click" // Clicked on supporter CTA
		case impressionLogin = "impression_user_login"
		case impressionAccountSwitcher = "impression_multi_account_switch_landing"
	}

	private static func getBaseProps() -> [String: Any?] {
		[
			"cpu_core_count": ProcessInfo().processorCount,
			"rendered_locale": Bundle.main.preferredLocalizations[0]
			// More entries will be added in the future
		]
	}

	private static let log = Logger(category: "AnalyticsWrapper")

	static func event(type: EventType, properties: [String: Any?] = [:]) {
		let combinedProps = getBaseProps().merging(properties) { $1 }

		let typedProps = EventProperties()
		for (prop, val) in combinedProps {
			if val == nil {
				continue
			} else if let stringVal = val as? String {
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
		AnalyticsWrapper.log.debug("Tracking event <\(type.rawValue)>: \(properties.debugDescription)")
		Analytics.trackEvent(type.rawValue, withProperties: typedProps)
	}
}
