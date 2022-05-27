//
//  StringRandom.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 14/5/22.
//

import Foundation

extension String {
    static func random(count: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<count).map { _ in letters.randomElement()! })
    }
}
