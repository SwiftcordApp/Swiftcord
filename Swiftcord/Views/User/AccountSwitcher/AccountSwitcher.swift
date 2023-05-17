//
//  AccountSwitcher.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 4/9/22.
//

import SwiftUI
import DiscordKitCore
import DiscordKit
import os
import Sentry

public class AccountSwitcher: NSObject, ObservableObject {
	@Published var accounts: [AccountMeta] = []

	static let META_KEY = "accountsMeta"
	static let ACTIVE_KEY = "activeAcct"
	static let log = Logger(category: "AccountSwitcher")

	static let keyPrefixesToRemove = [
		"lastCh.",
		"lastSelectedGuild"
	]

	/// The token pending to be persisted in token storage
	private var pendingToken: String?
	/// A cache for storing decoded tokens from UserDefaults
	private var tokens: [String: String] = [:]

	// MARK: - Account metadata methods
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
	func removeAccount(for id: Snowflake) {
		accounts.removeAll(identifiedBy: id)
	}

	// MARK: - Secure token storage methods
	func saveToken(for id: Snowflake, token: String) {
		tokens[id] = token
		// Keychain.save(key: "\(SwiftcordApp.tokenKeychainKey).\(id)", data: token)
		writeTokenCache()
	}
	func getToken(for id: Snowflake) -> String? { tokens[id] }
	func removeToken(for id: Snowflake) {
		tokens.removeValue(forKey: id)
		writeTokenCache()
	}
	func writeTokenCache() {
		guard let encodedTokens = try? JSONEncoder().encode(tokens) else {
			Self.log.error("Failed to encode token cache to write to keychain!")
			return
		}
		Keychain.save(key: SwiftcordApp.tokenKeychainKey, data: encodedTokens)
	}
	func populateTokenCache() {
		tokens = [:]
		guard let encoded = Keychain.loadData(key: SwiftcordApp.tokenKeychainKey) else {
			Self.log.warning("Token data doesn't exist in keychain")
			return
		}
		guard let loadedTokens = try? JSONDecoder().decode([String: String].self, from: encoded) else {
			Self.log.warning("Failed to decode tokens, might be corrupted. Resetting token storage...")
			writeTokenCache()
			return
		}
		tokens = loadedTokens
	}

	// Static to allow using elsewhere
	static func clearAccountSpecificPrefKeys() {
		for key in UserDefaults.standard.dictionaryRepresentation().keys
		where keyPrefixesToRemove.contains(where: { key.starts(with: $0) }) {
			UserDefaults.standard.removeObject(forKey: key)
		}
	}
	func logOut(id: Snowflake) async {
		guard let token = getToken(for: id) else { return }
		removeToken(for: id)

		DispatchQueue.main.async { [weak self] in
			withAnimation {
				self?.removeAccount(for: id)
				self?.writeAccounts()

				// Actions to take if the account being logged out is the current one
				if UserDefaults.standard.string(forKey: AccountSwitcher.ACTIVE_KEY) == id {
					self?.setActiveAccount(id: self?.accounts.first?.id)
				}
			}
		}

		let tempAPI = DiscordREST()
		tempAPI.setToken(token: token)
		try? await tempAPI.logOut()

		// Clear the current user in the Sentry SDK
		SentrySDK.setUser(nil)
	}
	/// Mark the current user as invalid - i.e. remove it from the token store and acc
	///
	/// The next account (if present) will automatically become "active" after invalidating the current one.
	/// > Note: The user will not be signed out from the Discord API
	func invalidate() {
		guard let id = getActiveID() else { return }
		removeToken(for: id)
		removeAccount(for: id)
		print("has accounts? \(!accounts.isEmpty)")
		setActiveAccount(id: accounts.first?.id)
	}

	func setPendingToken(token: String) {
		pendingToken = token
	}
	func setActiveAccount(id: Snowflake?) {
		AccountSwitcher.clearAccountSpecificPrefKeys() // Clear account specific UserDefault keys
		if let id = id {
			// ID is always assumed to be correct
			UserDefaults.standard.set(id, forKey: AccountSwitcher.ACTIVE_KEY)
		} else {
			UserDefaults.standard.removeObject(forKey: AccountSwitcher.ACTIVE_KEY)
		}
	}

	// Multiple sanity checks ensure account meta is valid, if not, repair is attempted
	func getActiveToken() -> String? {
		// If a token is found in the old keychain key, return that to allow logging in
		if let oldToken = Keychain.load(key: SwiftcordApp.legacyTokenKeychainKey) {
			AccountSwitcher.log.info("Found token in old key! Logging in with this token...")
			return oldToken
		}
		let storedActiveID = getActiveID()
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
	func getActiveID() -> String? { UserDefaults.standard.string(forKey: AccountSwitcher.ACTIVE_KEY) }

	func onSignedIn(with user: CurrentUser) {
		// Migrate from old keychain key to new keys
		if let oldToken = Keychain.load(key: SwiftcordApp.legacyTokenKeychainKey) {
			Keychain.remove(key: SwiftcordApp.legacyTokenKeychainKey)
			saveToken(for: user.id, token: oldToken)
			Self.log.info("Migrated old token to new storage")
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
			Self.log.info("User meta for current user is outdated, it will be updated")
			accounts[curUserIdx] = AccountMeta(user: user)
			inconsistency = true
		}

		// Check for duplicates and remove them if any
		var accountIDs: [Snowflake] = []
		for (idx, account) in accounts.enumerated() {
			if accountIDs.contains(account.id) ||
				getToken(for: account.id) == nil {
				guard idx != curUserIdx else {
					Self.log.error("Attempting to remove the current user's meta!")
					break
				}
				// Invalid account
				accounts.remove(at: idx)
				inconsistency = true
				Self.log.warning("Found dupe, or no token found in keychain for account \(account.id)")
			} else { accountIDs.append(account.id) }
		}

		if inconsistency {
			Self.log.warning("Fixing account meta inconsistencies")
			writeAccounts()
		}

		// Move the current active account to the top
		// Remove current active account and reinsert it at the top
		guard !accounts.isEmpty else {
			Self.log.warning("Accounts empty! This should never happen!")
			return
		}
		accounts.insert(accounts.remove(at: accounts.firstIndex { $0.id == user.id } ?? 0), at: 0)

		// Set Sentry user ID in the SDK to link bugs with user reports
		SentrySDK.setUser(.init(userId: user.id))
	}

	override init() {
		super.init()
		loadAccounts()
		populateTokenCache()
	}
}
