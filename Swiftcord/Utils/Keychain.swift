//
//  Keychain.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//
//  Adapted from: https://stackoverflow.com/a/37539998 (actually had a Swift 5 example)

import Foundation
import Security

public class Keychain {
    private static let tag = Bundle.main.bundleIdentifier!.data(using: .utf8)!

	@discardableResult
	fileprivate class func _save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "\(Bundle.main.bundleIdentifier!).\(key)",
            kSecAttrApplicationTag: tag,
            kSecValueData: data
		] as [CFString: Any] as CFDictionary

        SecItemDelete(query)

        return SecItemAdd(query, nil)
    }

	@discardableResult
	fileprivate class func _remove(key: String) -> OSStatus {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "\(Bundle.main.bundleIdentifier!).\(key)",
            kSecAttrApplicationTag: tag,
            kSecMatchLimit: kSecMatchLimitOne
		] as [CFString: Any] as CFDictionary

        return SecItemDelete(query)
    }

	public class func load(key: String) -> String? {
        guard let data: Data = loadData(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

	public class func loadData(key: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "\(Bundle.main.bundleIdentifier!).\(key)",
            kSecReturnData: true,
            kSecAttrApplicationTag: tag,
            kSecMatchLimit: kSecMatchLimitOne
		] as [CFString: Any] as CFDictionary

        var dataTypeRef: AnyObject?

        let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)

        guard status == noErr else { return nil }
        return dataTypeRef as? Data
    }

	private class func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)

        let swiftString: String = cfStr as String
        return swiftString
    }
}

// Publically exposed methods
public extension Keychain {
	class func save(key: String, data: String) {
		save(key: key, data: data.data(using: .utf8)!)
	}
	static func save(key: String, data: Data, canSync: Bool = true) {
		DispatchQueue.global(qos: .utility).async { _save(key: key, data: data) }
	}
	static func remove(key: String) {
		DispatchQueue.global(qos: .utility).async { _remove(key: key) }
	}
}

public extension Data {
    init<T>(from value: T) {
        var value = value
        var tempData = Data()
        withUnsafePointer(to: &value) { (ptr: UnsafePointer<T>) -> Void in
			tempData = Data( buffer: UnsafeBufferPointer(start: ptr, count: 1))
        }
        self.init(tempData)
    }

    func to<T>(type: T.Type) -> T {
		self.withUnsafeBytes { $0.load(as: T.self) }
    }
}
