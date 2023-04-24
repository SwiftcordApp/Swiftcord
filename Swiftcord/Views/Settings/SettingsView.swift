//
//  PreferencesView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/3/22.
//

import SwiftUI
import DiscordKit
import DiscordKitCore

struct SettingsView: View {
    @EnvironmentObject var gateway: DiscordGateway

	@AppStorage("local.newSettingsUI") private var newUI = true

    var body: some View {
        if let user = gateway.cache.user {
			if #available(macOS 13.0, *), newUI {
				ModernSettings(user: user)
			} else {
				LegacySettings(user: user)
			}
        } else {
			NoGatewayView()
        }
    }
}

private extension SettingsView {
	struct LegacySettings: View {
		let user: CurrentUser

		var body: some View {
			TabView {
				UserSettingsView(user: user).tabItem {
					Label("User", systemImage: "person.crop.circle")
				}

				BillingSettingsView().tabItem {
					Label("Billing", systemImage: "dollarsign.circle")
				}

				AppSettingsView().tabItem {
					Label("settings.app", systemImage: "macwindow")
				}

				ActivitySettingsView().tabItem {
					Label("Activity", systemImage: "hammer")
				}

				MiscSettingsView().tabItem {
					Label("Others", systemImage: "ellipsis")
				}
			}
			.frame(width: 900, height: 600)
		}
	}
	@available(macOS 13, *)
	struct ModernSettings: View {
		let user: CurrentUser

		private struct Page: Hashable, Identifiable {
			internal init(_ name: Name, icon: Icon? = nil, children: [SettingsView.ModernSettings.Page] = []) {
				self.children = children
				self.name = name
				self.icon = icon
			}

			var id: String { name.rawValue }

			let children: [Page]
			let name: Name
			var nameString: LocalizedStringKey { LocalizedStringKey(name.rawValue) }
			let icon: Icon?

			struct Icon: Hashable {
				enum IconResource: Equatable, Hashable {
					case system(_ name: String)
					case asset(_ name: String)
				}

				let baseColor: Color
				let icon: IconResource
			}

			enum Name: String {
				// MARK: User Settings
				case userSection = "User Settings"
				case account = "My Account"
				case profile = "User Profile"
				case privacy = "Privacy & Safety"
				case apps = "Authorized Apps"
				case connections = "Connections"
				case logOut = "Log Out"
				// MARK: Payment Settings
				case paymentSection = "Payment Settings"
				case nitro = "Nitro"
				case boost = "Server Boost"
				case subscriptions = "Subscriptions"
				case gift = "Gift Inventory"
				case billing = "Billing"
				// MARK: App Settings
				case appSection = "App Settings"
				case appearance = "settings.app.appearance"
				case accessibility = "settings.app.accessibility"
				case voiceVideo = "settings.app.voiceVideo"
				case textImages = "settings.app.textImages"
				case notifs = "settings.app.notifs"
				case keybinds = "settings.app.keybinds"
				case lang = "settings.app.lang"
				case streamer = "settings.app.streamer"
				case advanced = "settings.app.advanced"
				case credits = "settings.app.credits"
				case debug = "settings.app.debug"
			}
		}
		private static let pages: [Page] = [
			.init(.userSection, children: [
				.init(.account, icon: .init(baseColor: .blue, icon: .system("person.fill"))),
				.init(.profile, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				.init(.privacy, icon: .init(baseColor: .red, icon: .system("shield.lefthalf.filled")))
			]),
			.init(.paymentSection, children: [
				.init(.nitro, icon: .init(baseColor: .gray, icon: .asset("NitroSubscriber"))),
				.init(.boost, icon: .init(baseColor: .green, icon: .system("person.crop.circle"))),
				.init(.subscriptions, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				.init(.gift, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				.init(.billing, icon: .init(baseColor: .blue, icon: .system("person.crop.circle")))
			]),
			.init(.appSection, children: [
				.init(.appearance, icon: .init(baseColor: .black, icon: .system("person.crop.circle"))),
				.init(.accessibility, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				.init(.voiceVideo, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				.init(.textImages, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				.init(.notifs, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				.init(.keybinds, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				.init(.lang, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				.init(.streamer, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				.init(.advanced, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				.init(.credits, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				.init(.debug, icon: .init(baseColor: .blue, icon: .system("person.crop.circle")))
			])
		]

		@State private var selectedPage = pages.first!.children.first!
		@State private var filter = ""

		@ViewBuilder
		private func navigationItem(item: Page) -> some View {
			if filter.isEmpty || item.name.rawValue.lowercased().contains(filter.lowercased()) {
				NavigationLink(value: item) {
					if item.name == .account {
						HStack {
							BetterImageView(url: user.avatarURL(size: 160))
								.frame(width: 40, height: 40)
								.clipShape(Circle())
							VStack(alignment: .leading) {
								Text(user.username).font(.headline)
								Text("Discord Account").font(.caption)
							}
						}
					} else {
						Label {
							Text(item.nameString)
						} icon: {
							if let icon = item.icon {
								Group {
									switch icon.icon {
									case .system(let name):
										Image(systemName: name)
									case .asset(let name):
										Image(name).resizable().padding(2)
									}
								}
								.foregroundColor(.primary)
								.frame(width: 20, height: 20)
								.background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(icon.baseColor.gradient))
							} else {
								EmptyView()
							}
						}
					}
				}
			}
		}

		var body: some View {
			NavigationSplitView {
				List(Self.pages, selection: $selectedPage) { category in
					Section(category.nameString) {
						ForEach(category.children) { child in
							navigationItem(item: child)
						}
					}
				}.navigationSplitViewColumnWidth(215)
			} detail: {
				ScrollView {
					Group {
						switch selectedPage.name {
						case .appearance:
							AppSettingsAppearanceView()
						case .accessibility:
							AppSettingsAccessibilityView()
						case .account:
							UserSettingsAccountView(user: user)
						case .profile:
							UserSettingsProfileView(user: user)
						case .privacy:
							UserSettingsPrivacySafetyView()
						case .advanced:
							AppSettingsAdvancedView()
						case .credits:
							CreditsView()
						case .debug:
							DebugSettingsView()
						default:
							Text("Unimplemented view: \(selectedPage.name.rawValue)")
						}
					}.padding(20)
				}.navigationSplitViewColumnWidth(500)
			}
			.searchable(text: $filter, placement: .sidebar)
			.navigationTitle(selectedPage.nameString)
			.frame(minHeight: 470)
		}
	}

	struct NoGatewayView: View {
		var body: some View {
			VStack(spacing: 8) {
				Image(systemName: "wifi.slash").font(.system(size: 30)).foregroundColor(.accentColor)
				Text("Gateway isn't connected")
					.font(.title)
					.padding(.top, 8)
				Text("Settings can only be modified after logging in and while the gateway is connected.")
					.opacity(0.75)
					.multilineTextAlignment(.center)
					.fixedSize(horizontal: false, vertical: true)
			}
			.frame(width: 400)
			.padding(16)
		}
	}
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
