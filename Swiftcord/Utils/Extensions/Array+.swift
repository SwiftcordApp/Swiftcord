//
//  +Array.swift
//  Swiftcord
//
//  Created by Selim GORUR on 21/05/2022.
//

import Foundation

extension Array {
	func chunks(_ chunkSize: Int) -> [[Element]] {
		return stride(from: 0, to: self.count, by: chunkSize).map {
			Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
		}
	}
}
