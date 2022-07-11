//
//  Color+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import SwiftUI

// Create color with hex int
extension Color {
    init(hex: Int, alpha: Double = 1) {
        self.init(.sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension Color {
	func modifyingSaturation(_ adjustment: CGFloat) -> Color {
		return modifyingHSB(1, adjustment, 1)
	}
	func modifyingBrightness(_ adjustment: CGFloat) -> Color {
		return modifyingHSB(1, 1, adjustment)
	}

	func modifyingHSB(_ hueAdj: CGFloat, _ saturationAdj: CGFloat, _ brightnessAdj: CGFloat) -> Color {
		var hue: CGFloat = 0
		var saturation: CGFloat = 0
		var brightness: CGFloat = 0
		var alpha: CGFloat = 0
		NSColor(self).usingColorSpace(.sRGB)!.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		return Color(
			hue: hue * hueAdj,
			saturation: saturation * saturationAdj,
			brightness: brightness * brightnessAdj,
			opacity: alpha
		)
	}
}

extension Color {
	var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
		var r: CGFloat = 0 // swiftlint:disable:this identifier_name
		var g: CGFloat = 0 // swiftlint:disable:this identifier_name
		var b: CGFloat = 0 // swiftlint:disable:this identifier_name
		var o: CGFloat = 0 // swiftlint:disable:this identifier_name

		NSColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
		return (r, g, b, o)
	}

	/// Returns a suitable text color for use on a background
	func contrastColor(darkCol: Color = .black, lightCol: Color = .white) -> Color {
		components.opacity < 0.5
			? .primary
			: (components.red + components.green + components.blue)/3 > 128 ? darkCol : lightCol
	}
}
