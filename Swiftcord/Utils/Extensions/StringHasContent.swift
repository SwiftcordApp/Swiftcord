//
//  StringHasContent.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 14/5/22.
//

import Foundation

extension String {
    /// Returns true if the string has any content after stripping spaces/newlines
    func hasContent() -> Bool {
        let text = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return !text.isEmpty
    }
}
