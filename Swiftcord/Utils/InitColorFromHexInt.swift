//
//  InitColorFromHexInt.swift
//  Native Discord
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
