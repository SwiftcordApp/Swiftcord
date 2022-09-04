//
//  AccountSwitcher.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 4/9/22.
//

import Foundation
import DiscordKitCommon

class AccountSwitcher: NSObject, ObservableObject {
	@Published var accounts: [AccountMeta] = []

	static let META_KEY = "accountsMeta"

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

	func onSignedIn(with user: CurrentUser) {
		if !accounts.contains(where: { $0.id == user.id }) {
			accounts.insert(.init(user: user), at: 0)
			writeAccounts()
		}
	}

	override init() {
		super.init()
		loadAccounts()
		//UserDefaults.standard.addObserver(self, forKeyPath: "accountsMeta", options: NSKeyValueObservingOptions.new, context: nil)
	}
}
