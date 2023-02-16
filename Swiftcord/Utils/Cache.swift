//
//  Cache.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 3/6/22.
//

import Foundation

// From https://www.swiftbysundell.com/articles/caching-in-swift/
final class Cache<Key: Hashable, Value> {
	private let wrapped = NSCache<WrappedKey, Entry>()

	func insert(_ value: Value, forKey key: Key) {
		let entry = Entry(value: value)
		wrapped.setObject(entry, forKey: WrappedKey(key))
	}

	func value(forKey key: Key) -> Value? {
		let entry = wrapped.object(forKey: WrappedKey(key))
		return entry?.value
	}

	func removeValue(forKey key: Key) {
		wrapped.removeObject(forKey: WrappedKey(key))
	}
}

extension Cache {
	subscript(key: Key) -> Value? {
		get { value(forKey: key) }
		set {
			guard let value = newValue else {
				// If nil was assigned using our subscript,
				// then we remove any value for that key:
				removeValue(forKey: key)
				return
			}

			insert(value, forKey: key)
		}
	}
}

private extension Cache {
	final class WrappedKey: NSObject {
		let key: Key

		init(_ key: Key) { self.key = key }

		override var hash: Int { key.hashValue }

		override func isEqual(_ object: Any?) -> Bool {
			guard let value = object as? WrappedKey else {
				return false
			}

			return value.key == key
		}
	}
}

private extension Cache {
	final class Entry {
		let value: Value

		init(value: Value) {
			self.value = value
		}
	}
}
