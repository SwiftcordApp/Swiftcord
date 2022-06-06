//
//  AppSettingsAccessibilityView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/6/22.
//

import SwiftUI

struct AppSettingsAccessibilityView: View {
	@AppStorage("stickerAlwaysAnim") private var alwaysAnimStickers = true

    var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("settings.app.accessibility").font(.title)

			VStack(alignment: .leading) {
				Toggle(isOn: $alwaysAnimStickers) {
					Text("Always animate stickers").frame(maxWidth: .infinity, alignment: .leading)
				}
				.toggleStyle(.switch)
				.tint(.green)
				if !alwaysAnimStickers {
					Text("settings.app.accessibility.sticker.animInteraction").font(.caption)
				}
			}
		}
    }
}
