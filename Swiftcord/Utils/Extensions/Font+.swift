//
//  Font+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 27/2/22.
//
//  Make fonts more closely match

import SwiftUI

extension Font {
    // Large title
    public static var largeTitle: Font {
		let size = NSFont.preferredFont(forTextStyle: .largeTitle).pointSize * fontScale
		return Font.custom("Ginto Bold", size: size, relativeTo: .largeTitle)
    }

    // Headline
    public static var headline: Font {
		let size = NSFont.preferredFont(forTextStyle: .headline).pointSize * fontScale
		return Font.custom("Ginto Medium", size: size, relativeTo: .headline)
    }

    // Titles
    public static var title: Font {
		let size = NSFont.preferredFont(forTextStyle: .title1).pointSize * fontScale
		return Font.custom("Ginto Bold", size: size, relativeTo: .title)
    }
    public static var title2: Font {
		let size = NSFont.preferredFont(forTextStyle: .title2).pointSize * fontScale
		return Font.custom("Ginto Medium", size: size, relativeTo: .title2)
    }
    public static var title3: Font {
		let size = NSFont.preferredFont(forTextStyle: .title3).pointSize * fontScale
		return Font.custom("Ginto Medium", size: size, relativeTo: .title3)
    }
	
	public static var callout: Font {
		let size = NSFont.preferredFont(forTextStyle: .callout).pointSize * fontScale
		return .system(size: size, weight: .semibold, design: fontDesign)
	}
	
	public static var body: Font {
		let size = NSFont.preferredFont(forTextStyle: .body).pointSize * fontScale
		return .system(size: size, weight: .regular, design: fontDesign)
	}
	
	public static var footnote: Font {
		let size = NSFont.preferredFont(forTextStyle: .footnote).pointSize * fontScale
		return .system(size: size, weight: .regular, design: fontDesign)
	}
	
	public static var messageInput: Font {
		let size = NSFont.preferredFont(forTextStyle: .title2).pointSize * fontScale
		return .system(size: size, weight: .light, design: fontDesign)
	}
	
	// Message
	public static var appMessage: Self {
		if #available(macOS 13.0, *) {
			return .system(size: appMessageFontSize, weight: .regular, design: fontDesign)
		} else {
			return .system(size: appMessageFontSize, weight: .regular)
		}
	}
	
	// Message
	public static var appMessageFontSize: CGFloat {
		let defaultFont: NSFont = .labelFont(ofSize: 15)
		let fontSize = defaultFont.pointSize
		let scaledFontSize = fontSize * fontScale
		return scaledFontSize
	}
	
	static var fontDesign: Font.Design {
		@AppStorage("isEnabledRoundedFont") var isEnabledRoundedFont = false
		return isEnabledRoundedFont ? .rounded : .default
	}
}

// MARK: - Helpers
private extension Font {
	static var fontScale: CGFloat {
		@AppStorage("fontSizeScale") var fontScale = 1.0
		return CGFloat(fontScale)
	}
}
