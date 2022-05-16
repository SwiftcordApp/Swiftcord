//
//  Keychain.swift
//  DiscordKitCommon
//
//  Created by Vincent Kwok on 21/2/22.
//
//  Adapted from: https://stackoverflow.com/a/37539998 (actually had a Swift 5 example)

import Foundation
import Security

public class Keychain {
    static let tag = Bundle.main.bundleIdentifier!.data(using: .utf8)!

	@discardableResult
    public class func save(key: String, data: String) -> OSStatus {
        return save(key: key, data: data.data(using: .utf8)!)
    }

	@discardableResult
	public class func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : "\(Bundle.main.bundleIdentifier!).\(key)",
            kSecAttrApplicationTag as String: tag,
            kSecValueData as String   : data
        ] as [String : Any]

        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }

	@discardableResult
	public class func remove(key: String) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : "\(Bundle.main.bundleIdentifier!).\(key)",
            kSecAttrApplicationTag as String: tag,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ] as [String : Any]

        return SecItemDelete(query as CFDictionary)
    }

	public class func load(key: String) -> String? {
        guard let d: Data = loadData(key: key)
        else { return nil }
        return String(data: d, encoding: .utf8)
    }
	
	public class func loadData(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : "\(Bundle.main.bundleIdentifier!).\(key)",
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecAttrApplicationTag as String: tag,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == noErr else { return nil }
        return dataTypeRef as! Data?
    }

	public class func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)

        let swiftString: String = cfStr as String
        return swiftString
    }
}

public extension Data {
    init<T>(from value: T) {
        var value = value
        var d = Data()
        withUnsafePointer(to: &value, { (ptr: UnsafePointer<T>) -> Void in
            d = Data( buffer: UnsafeBufferPointer(start: ptr, count: 1))
        })
        self.init(d)
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}
