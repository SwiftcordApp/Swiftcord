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
        return Font.custom("Ginto Bold", size: NSFont.preferredFont(forTextStyle: .largeTitle).pointSize)
    }
    
    // Headline
    public static var headline: Font {
        return Font.custom("Ginto Medium", size: NSFont.preferredFont(forTextStyle: .headline).pointSize)
    }
    
    // Titles
    public static var title: Font {
        return Font.custom("Ginto Bold", size: NSFont.preferredFont(forTextStyle: .title1).pointSize)
    }
    public static var title2: Font {
        return Font.custom("Ginto Medium", size: NSFont.preferredFont(forTextStyle: .title2).pointSize)
    }
    public static var title3: Font {
        return Font.custom("Ginto Medium", size: NSFont.preferredFont(forTextStyle: .title3).pointSize)
    }
}
