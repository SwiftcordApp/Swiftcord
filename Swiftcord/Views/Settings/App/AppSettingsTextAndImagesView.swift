//
//  AppSettingsMessageView.swift
//  Swiftcord
//
//  Created by Lucas Romano Marquez Rizzi on 17/10/23.
//

import SwiftUI

struct AppSettingsTextAndImagesView: View {
	@AppStorage("fontSizeScale") private var fontScale = 1.0
	@AppStorage("isEnabledRoundedFont") private var isEnabledRoundedFont = false
	
	var body: some View {
		Section {
			VStack(alignment: .leading, spacing: 0) {
				Slider(value: $fontScale, in: 0.4...1.4, step: 0.1) {
					Text("Font scale: ") +
					Text("\(fontScale, specifier: "%.2f")")
						.bold()
				} minimumValueLabel: {
					Text("Small").font(.subheadline).opacity(0.75)
				} maximumValueLabel: {
					Text("Biggers").font(.subheadline).opacity(0.75)
				}
			}
			
			if #available(macOS 13.0, *) {
				Toggle("Rounded font", isOn: $isEnabledRoundedFont)
			}
		} header: {
			Text("Texts")
		}
		
		Section {
			Text("Unimplemented view: Images")
		} header: {
			Text("Images")
		}
	}
}
