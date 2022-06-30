//
//  Array+.swift
//  Swiftcord
//
//  Created by Andrew Glaze on 6/29/22.
//

extension BidirectionalCollection where Iterator.Element: Equatable {
	typealias Element = Self.Iterator.Element

	func after(_ item: Element, loop: Bool = false) -> Element? {
		if let itemIndex = self.firstIndex(of: item) {
			let lastItem: Bool = (index(after: itemIndex) == endIndex)
			if loop && lastItem {
				return self.first
			} else if lastItem {
				return nil
			} else {
				return self[index(after: itemIndex)]
			}
		}
		return nil
	}

	func before(_ item: Element, loop: Bool = false) -> Element? {
		if let itemIndex = self.firstIndex(of: item) {
			let firstItem: Bool = (itemIndex == startIndex)
			if loop && firstItem {
				return self.last
			} else if firstItem {
				return nil
			} else {
				return self[index(before: itemIndex)]
			}
		}
		return nil
	}
}
