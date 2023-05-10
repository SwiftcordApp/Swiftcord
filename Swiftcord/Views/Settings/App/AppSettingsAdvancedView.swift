//
//  AppSettingsAdvancedView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 7/7/22.
//

import SwiftUI
import AppCenterAnalytics

struct AppSettingsAdvancedView: View {
	@AppStorage("local.analytics") private var analyticsEnabled = true
	@State private var hasToggledAnalytics = false

    var body: some View {
		Section("settings.app.advanced.analytics") {
			Toggle(isOn: $analyticsEnabled) {
				Text("settings.app.advanced.analytics.option")
					.frame(maxWidth: .infinity, alignment: .leading)
			}.onChange(of: analyticsEnabled) { enabled in
				hasToggledAnalytics = true
				if enabled {
					AnalyticsWrapper.event(type: .analyticsEnabled, properties: [:])
				} else {
					AnalyticsWrapper.event(type: .analyticsDisabled, properties: [:])
				}
				Analytics.enabled = enabled
			}.disabled(hasToggledAnalytics)

			Text("settings.app.advanced.analytics.caption").font(.callout).foregroundColor(.secondary)
		}

		Section {
			Text("settings.app.advanced.crashes")
		}
    }
}
