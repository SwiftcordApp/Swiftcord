//
//  CodableThrowable.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 9/3/22.
//

import Foundation

struct Throwable<T: Decodable>: Decodable {
    let result: Result<T, Error>

    init(from decoder: Decoder) throws {
        result = Result(catching: { try T(from: decoder) })
    }
}
