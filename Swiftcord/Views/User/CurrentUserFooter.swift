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
import DiscordKit

struct CurrentUserFooter: View {
    let user: CurrentUser

	@State var userPopoverPresented = false
	@State var switcherPresented = false
	@State var loginPresented = false
	@State var showQR = false
	@State var switcherHelpPresented = false

	@EnvironmentObject var switcher: AccountSwitcher
	@EnvironmentObject var gateway: DiscordGateway

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
							
						} label: {
							// Not possible to set custom image size and color
							Image(systemName: "circle.fill")
							Text("user.presence.online")
						}
						Divider()
						Button {
							
						} label: {
							Image(systemName: "moon.fill")
							Text("user.presence.idle")
						}
						Button {
							
						} label: {
							Image(systemName: "minus.circle")
							Text("user.presence.dnd")
						}
						Button {
							
						} label: {
							Image(systemName: "circle")
							Text("user.presence.invisible")
						}
					} label: {
						Label(curUserPresence.toLocalizedString(), systemImage: "circle")
					}
					.controlSize(.large)
					Button {
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

struct CurrentUserFooter_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
