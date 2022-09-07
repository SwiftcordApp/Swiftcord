//
//  CurrentUserFooter.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/3/22.
//
//

import SwiftUI
import CachedAsyncImage
import DiscordKitCommon
import DiscordKitCore
import DiscordKit

struct CurrentUserFooter: View {
    let user: CurrentUser

	@State var customStatusPresented = false
	@State var userPopoverPresented = false
	@State var switcherPresented = false
	@State var loginPresented = false
	@State var showQR = false
	@State var switcherHelpPresented = false

	@EnvironmentObject var switcher: AccountSwitcher
	@EnvironmentObject var gateway: DiscordGateway
	@EnvironmentObject var rest: DiscordREST

	private static let presenceIconMapping: [PresenceStatus : String] = [
		.online: "circle.fill",
		.idle: "moon.fill",
		.dnd: "minus.circle",
		.invisible: "circle"
	]

	private func updatePresence(with presence: PresenceStatus) {
		gateway.send(
			op: .presenceUpdate,
			data: GatewayPresenceUpdate(since: 0, activities: [], status: presence, afk: false)
		)
		Task {
			await rest.updateSettingsProto(proto: try! Discord_UserSettings.with {
				$0.status = StatusSettings.with {
					$0.status = .init(stringLiteral: presence.rawValue)
				}
			}.serializedData())
		}
	}

    var body: some View {
		let curUserPresence = gateway.presences[user.id]?.status ?? .offline

		Button {
			userPopoverPresented = true
			AnalyticsWrapper.event(type: .openPopout, properties: [
				"type": "User Status Menu",
				"other_user_id": user.id
			])
		} label: {
			HStack(spacing: 8) {
				AvatarWithPresence(
					avatarURL: user.avatarURL(),
					presence: curUserPresence,
					animate: false
				)
				.controlSize(.small)
				.padding(.leading, 8)

				VStack(alignment: .leading, spacing: 0) {
					Text(user.username).font(.headline)
					Text("#" + user.discriminator).font(.system(size: 12)).opacity(0.75)
				}
				Spacer()

				// The hidden selector for opening the preferences window
				// is probably removed in macOS 13. Should check if this
				// is still broken once macOS 13 is stable.
				if #available(macOS 13.0, *) {
					EmptyView()
				} else {
					Button(action: {
						NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
					}, label: {
						Image(systemName: "gearshape.fill")
							.font(.system(size: 18))
							.opacity(0.75)
					})
					.buttonStyle(.plain)
					.padding(.trailing, 14)
				}
			}
			.frame(height: 52)
			.background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
		}
		.buttonStyle(.plain)
		.popover(isPresented: $userPopoverPresented) {
			MiniUserProfileView(user: User(from: user), profile: .constant(UserProfile(
				connected_accounts: [],
				user: User(from: user)
			))) {
				VStack(spacing: 4) {
					if !(user.bio?.isEmpty ?? true) { Divider() }

					// Set presence
					Menu {
						Button {
							updatePresence(with: .online)
						} label: {
							// Not possible to set custom image size and color
							Image(systemName: Self.presenceIconMapping[.online]!)
							Text("user.presence.online")
						}
						Divider()
						Button {
							updatePresence(with: .idle)
						} label: {
							Image(systemName: Self.presenceIconMapping[.idle]!)
							Text("user.presence.idle")
						}
						Button {
							updatePresence(with: .dnd)
						} label: {
							Image(systemName: Self.presenceIconMapping[.dnd]!)
							Text("user.presence.dnd")
						}
						Button {
							updatePresence(with: .invisible)
						} label: {
							Image(systemName: Self.presenceIconMapping[.invisible]!)
							Text("user.presence.invisible")
						}
					} label: {
						Label(
							curUserPresence.toLocalizedString(),
							systemImage: Self.presenceIconMapping[curUserPresence] ?? "circle"
						)
					}
					.controlSize(.large)
					Button {
						customStatusPresented = true
					} label: {
						Label("Set Custom Status", systemImage: "face.smiling")
							.frame(maxWidth: .infinity, alignment: .leading)
					}
					.buttonStyle(FlatButtonStyle(outlined: true, text: true))
					.controlSize(.small)

					Divider()

					Button {
						switcherPresented = true
						AnalyticsWrapper.event(type: .impressionAccountSwitcher)
					} label: {
						Label("Switch Accounts", systemImage: "arrow.left.arrow.right")
							.frame(maxWidth: .infinity, alignment: .leading)
					}
					.buttonStyle(FlatButtonStyle(outlined: true, text: true))
					.controlSize(.small)
				}
			}
		}
		.sheet(isPresented: $switcherPresented) {
			accountSwitcher()
		}
		.sheet(isPresented: $customStatusPresented) {
			CustomStatusDialog(username: user.username, presented: $customStatusPresented)
		}
		.sheet(isPresented: $loginPresented) {
			ZStack(alignment: .topTrailing) {
				LoginView(shrink: true, showQR: showQR) { // Log in callback
					loginPresented = false
				}
				.frame(width: 450, height: 600)

				VStack(spacing: 16) {
					Button { loginPresented = false } label: {
						Image(systemName: "xmark")
							.contentShape(Circle())
							.font(.system(size: 24, weight: .bold))
							.opacity(0.75)
					}
					.buttonStyle(.plain)
					Button { showQR.toggle() } label: {
						Image(systemName: showQR ? "keyboard" : "qrcode")
							.contentShape(Rectangle())
							.font(.system(size: 24, weight: .medium))
							.opacity(0.75)
					}
					.buttonStyle(.plain)
					.frame(width: 24)
				}.padding(16)
			}
		}
    }
}
