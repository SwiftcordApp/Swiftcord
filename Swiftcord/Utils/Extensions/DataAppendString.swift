//
//  DataAppendString.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 14/5/22.
//

import Foundation

extension Data {
    public mutating func append(_ string: String, using: String.Encoding = .utf8) {
        self.append(string.data(using: using)!)
    }
}
