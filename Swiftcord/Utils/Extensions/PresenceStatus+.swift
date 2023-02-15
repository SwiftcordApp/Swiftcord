//
//  PresenceStatus+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 7/9/22.
//

import SwiftUI
import DiscordKitCore

extension PresenceStatus {
	func toLocalizedString() -> LocalizedStringKey {
		switch self {
		case .online: return "user.presence.online"
		case .idle: return "user.presence.idle"
		case .dnd: return "user.presence.dnd"
		case .offline: return "user.presence.offline"
		case .invisible: return "user.presence.invisible"
		}
	}
}
