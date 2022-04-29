//
//  File.swift
//  
//
//  Created by Vincent on 4/17/22.
//

import Foundation
import os

extension Logger {
    init(category: String) {
        self.init(subsystem: Bundle.main.bundleIdentifier ?? "", category: category)
    }
}
