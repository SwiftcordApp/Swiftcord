//
//  String+random.swift
//  DiscordAPI
//
//  Created by royal on 16/05/2022.
//

import Foundation

extension String {
	static func random(count: Int) -> String {
		let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		return String((0..<count).map{ _ in letters.randomElement()! })
	}
}
