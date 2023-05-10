//
//  AppSettingsAppearanceView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/6/22.
//

import SwiftUI

struct AppSettingsAppearanceView: View {
	let themes = ["light", "dark", "system"]

	@AppStorage("theme") private var selectedTheme = "system"

    var body: some View {
		Section {
			Picker("settings.app.appearance.theme", selection: $selectedTheme) {
				ForEach(themes, id: \.self) {
					Text($0.capitalized)
				}
			}.pickerStyle(.menu)
			Text("A known bug causes rendering glitches when the theme is switched from a theme that isn't the current system theme, to the system theme. It seems to be due to SwiftUI itself, but I'm looking for workarounds.")
				.font(.callout)
				.foregroundColor(.secondary)
		}
    }
}
