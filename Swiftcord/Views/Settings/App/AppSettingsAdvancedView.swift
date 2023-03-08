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
	@AppStorage("local.newSettingsUI") private var newSettingsUI = true
	@State private var hasToggledAnalytics = false

    var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("settings.app.advanced").font(.title)

			Text("settings.app.advanced.analytics")
				.font(.headline)
				.textCase(.uppercase)
				.opacity(0.75)
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
			Text("settings.app.advanced.analytics.caption").font(.caption)

			Divider()

			Text("settings.app.advanced.crashes")

			Divider()

			Text("Interface Trial")
				.font(.headline)
				.textCase(.uppercase)
				.opacity(0.75)
			VStack(alignment: .leading) {
				Toggle(isOn: $newSettingsUI) {
					Text("Try new Settings UI beta").frame(maxWidth: .infinity, alignment: .leading)
				}
				.toggleStyle(.switch)
				.tint(.green)
				if newSettingsUI {
					Text("Keep in mind that this new UI is not yet fully functional").font(.caption)
				}
			}
		}
    }
}
