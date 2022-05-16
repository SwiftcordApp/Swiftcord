//
//  CodableThrowable.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 9/3/22.
//

import Foundation

public struct DecodableThrowable<T: Decodable>: Decodable {
	public let result: Result<T, Error>

    public init(from decoder: Decoder) throws {
        result = Result(catching: { try T(from: decoder) })
    }
}
