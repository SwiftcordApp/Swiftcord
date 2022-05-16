//
//  Snowflake.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public struct Snowflake: Identifiable, Codable, ExpressibleByStringLiteral, CustomStringConvertible, Equatable, Comparable, Hashable {
	let rawValue: String

	/// Identifiable

	public var id: ObjectIdentifier {
		ObjectIdentifier(rawValue as AnyObject)
	}

	/// Codable

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let str = try? container.decode(String.self) {
			rawValue = str
			return
		}

		let num = try container.decode(Double.self)
		rawValue = String(num)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(rawValue)
	}

	/// ExpressibleByStringLiteral

	public init(stringLiteral value: StringLiteralType) {
		rawValue = value
	}

	/// CustomStringConvertible

	public var description: String {
		rawValue
	}

	/// Comparable

	public static func < (lhs: Snowflake, rhs: Snowflake) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}
