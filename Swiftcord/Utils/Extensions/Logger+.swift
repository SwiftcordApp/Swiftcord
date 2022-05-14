//
//  Logger+.swift
//  Swiftcord
//
//  Created by Vincent on 4/15/22.
//

import Foundation
import os

extension Logger {
    init(category: String) {
        self.init(subsystem: Bundle.main.bundleIdentifier ?? "", category: category)
    }
}
