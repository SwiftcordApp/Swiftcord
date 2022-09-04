//
//  AccountSwitcher.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 4/9/22.
//

import Foundation
import DiscordKitCommon
import os

class AccountSwitcher: NSObject, ObservableObject {
	@Published var accounts: [AccountMeta] = []

	static let META_KEY = "accountsMeta"
	static let log = Logger(category: "AccountSwitcher")

	func loadAccounts() {
		guard let dec = try? JSONDecoder().decode(
			[AccountMeta].self,
			from: UserDefaults.standard.data(forKey: AccountSwitcher.META_KEY) ?? Data())
		else {
			return
		}
		accounts = dec
	}
	func writeAccounts() {
		UserDefaults.standard.setValue(try? JSONEncoder().encode(accounts), forKey: AccountSwitcher.META_KEY)
	}

	func getActiveToken() -> String? {
		// If a token is found in the old keychain key, return that to allow logging in
		if let oldToken = Keychain.load(key: SwiftcordApp.tokenKeychainKey) {
			AccountSwitcher.log.info("Found token in old key! Logging in with this token...")
			return oldToken
		}
		guard let activeID = accounts.first?.id else { return nil } // Account not signed in
		guard let token = Keychain.load(key: "\(SwiftcordApp.tokenKeychainKey).\(activeID)") else {
			// Something is wrong too
			AccountSwitcher.log.error("Account meta exists for account ID \(activeID), but token was not found in keychain!")
			accounts.removeAll { acct in acct.id == activeID }
			return nil
		}
		return token
	}

	func onSignedIn(with user: CurrentUser) {
		// Migrate from old keychain key to new keys
		if let oldToken = Keychain.load(key: SwiftcordApp.tokenKeychainKey) {
			Keychain.remove(key: SwiftcordApp.tokenKeychainKey)
			Keychain.save(key: "\(SwiftcordApp.tokenKeychainKey).\(user.id)", data: oldToken)
			AccountSwitcher.log.info("Migrated old token to new keychain key format")
		}

		var inconsistency = false
		// Ensure the current account exists, if not add it
		if !accounts.contains(where: { $0.id == user.id }) {
			accounts.insert(.init(user: user), at: 0)
			inconsistency = true
		}
		// Check for duplicates and remove them if any
		var accountIDs: [Snowflake] = []
		for (idx, account) in accounts.enumerated() {
			if accountIDs.contains(account.id) ||
			    Keychain.load(key: "\(SwiftcordApp.tokenKeychainKey).\(account.id)") == nil {
				// Invalid account
				accounts.remove(at: idx)
				inconsistency = true
				AccountSwitcher.log.warning("Found dupe, or no token found in keychain for account \(account.id)")
			} else { accountIDs.append(account.id) }
		}

		if inconsistency {
			AccountSwitcher.log.warning("Fixing account meta inconsistencies")
			writeAccounts()
		}
	}

	override init() {
		super.init()
		loadAccounts()
	}
}
