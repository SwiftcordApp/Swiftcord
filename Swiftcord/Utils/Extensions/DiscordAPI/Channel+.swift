//
//  Channel+.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import DiscordKitCore

extension Channel {
	func label(_ users: [Snowflake: User] = [:]) -> String? {
		name ?? recipient_ids?
			.compactMap { users[$0]?.username }
			.joined(separator: ", ")
	}
}

extension Channel {
	func computedPermissions(
		guildID: Snowflake,
		member: Member, basePerms: Permissions
	) -> Permissions {
		if basePerms.contains(.administrator) {
			return .all
		}
		var permission = basePerms
		// Apply the overwrite for the @everyone permission
		if let everyoneOverwrite = permission_overwrites?.first(where: { $0.id == guildID }) {
			permission.applyOverwrite(everyoneOverwrite)
		}
		// Next, apply role-specific overwrites
		permission_overwrites?.forEach { overwrite in
			if member.roles.contains(overwrite.id) {
				permission.applyOverwrite(overwrite)
			}
		}
		// Finally, apply member-specific overwrites - must be done after all roles
		permission_overwrites?.forEach { overwrite in
			if member.user_id == overwrite.id {
				permission.applyOverwrite(overwrite)
			}
		}
		return permission
	}
}
