//
//  AccountSwitcher.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 4/9/22.
//

import SwiftUI
import DiscordKitCommon
import DiscordKitCore
import os

class AccountSwitcher: NSObject, ObservableObject {
	@Published var accounts: [AccountMeta] = []

	static let META_KEY = "accountsMeta"
	static let ACTIVE_KEY = "activeAcct"
	static let log = Logger(category: "AccountSwitcher")

	static let keyPrefixesToRemove = [
		"lastCh.",
		"lastSelectedGuild"
	]

	private var pendingToken: String?

	func loadAccounts() {
		guard let dec = try? JSONDecoder().decode(
			[AccountMeta].self,
			from: UserDefaults.standard.data(forKey: AccountSwitcher.META_KEY) ?? Data())
		else {
			return
		}
		accounts = dec
		print(accounts)
	}
	func writeAccounts() {
		UserDefaults.standard.setValue(try? JSONEncoder().encode(accounts), forKey: AccountSwitcher.META_KEY)
	}

	func saveToken(for id: Snowflake, token: String) {
		Keychain.save(key: "\(SwiftcordApp.tokenKeychainKey).\(id)", data: token)
	}
	func getToken(for id: Snowflake) -> String? {
		Keychain.load(key: "\(SwiftcordApp.tokenKeychainKey).\(id)")
	}

	// Static to allow using elsewhere
	static func clearAccountSpecificPrefKeys() {
		for key in UserDefaults.standard.dictionaryRepresentation().keys {
			for toRemove in keyPrefixesToRemove {
				if key.prefix(toRemove.count) == toRemove {
					UserDefaults.standard.removeObject(forKey: key)
					break
				}
			}
		}
	}
	func logOut(id: Snowflake) async {
		guard let token = getToken(for: id) else { return }
		await DiscordREST(token: token).logOut()
		Keychain.remove(key: "\(SwiftcordApp.tokenKeychainKey).\(id)")

		DispatchQueue.main.async { [weak self] in
			withAnimation {
				self?.accounts.removeAll { $0.id == id }
				self?.writeAccounts()

				// Actions to take if the account being logged out is the current one
				if UserDefaults.standard.string(forKey: AccountSwitcher.ACTIVE_KEY) == id {
					AccountSwitcher.clearAccountSpecificPrefKeys()
					if let firstID = self?.accounts.first?.id {
						self?.setActiveAccount(id: firstID)
					} else {
						UserDefaults.standard.removeObject(forKey: AccountSwitcher.ACTIVE_KEY)
					}
				}
			}
		}
	}

	func setPendingToken(token: String) {
		pendingToken = token
	}
	func setActiveAccount(id: Snowflake) {
		// ID is always assumed to be correct
		UserDefaults.standard.set(id, forKey: AccountSwitcher.ACTIVE_KEY)
		AccountSwitcher.clearAccountSpecificPrefKeys() // Clear account specific UserDefault keys
	}

	// Multiple sanity checks ensure account meta is valid, if not, repair is attempted
	func getActiveToken() -> String? {
		// If a token is found in the old keychain key, return that to allow logging in
		if let oldToken = Keychain.load(key: SwiftcordApp.tokenKeychainKey) {
			AccountSwitcher.log.info("Found token in old key! Logging in with this token...")
			return oldToken
		}
		let storedActiveID = UserDefaults.standard.string(forKey: AccountSwitcher.ACTIVE_KEY)
		guard let activeID = storedActiveID != nil && accounts.contains(where: { $0.id == storedActiveID })
			? storedActiveID
			: accounts.first?.id else { return nil } // Account not signed in
		guard let token = getToken(for: activeID) else {
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
			saveToken(for: user.id, token: oldToken)
			AccountSwitcher.log.info("Migrated old token to new keychain key format")
		}

		var inconsistency = false

		// If there's a token pending to be saved, save it under the current user ID
		if let newToken = pendingToken {
			pendingToken = nil
			saveToken(for: user.id, token: newToken)
			inconsistency = true
		}

		// Ensure the current account exists, if not add it
		if !accounts.contains(where: { $0.id == user.id }) {
			accounts.insert(.init(user: user), at: 0)
			inconsistency = true
		}
		let curUserIdx = accounts.firstIndex { $0.id == user.id }! // There will always be an entry for the current user
		// Ensure meta for current user is updated
		if accounts[curUserIdx].name != user.username ||
		    accounts[curUserIdx].discrim != user.discriminator ||
			accounts[curUserIdx].avatar != user.avatarURL(size: 80) {
			AccountSwitcher.log.info("User meta for current user is outdated, it will be updated")
			accounts[curUserIdx] = AccountMeta(user: user)
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

		// Move the current active account to the top
		// Remove current active account and reinsert it at the top
		accounts.insert(accounts.remove(at: accounts.firstIndex(where: { $0.id == user.id }) ?? 0), at: 0)
	}

	override init() {
		super.init()
		loadAccounts()
	}
}
