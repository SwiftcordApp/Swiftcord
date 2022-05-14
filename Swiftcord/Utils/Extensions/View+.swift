//
//  View+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 16/3/22.
//

import Foundation
import SwiftUI

extension View {
    /// https://stackoverflow.com/a/61985678/3393964
    public func cursor(_ cursor: NSCursor) -> some View {
        self.onHover { inside in
            if inside {
                cursor.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}
