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

    var body: some View {
        if let user = gateway.cache.user {
			if #available(macOS 13.0, *) {
				ModernSettings(user: user)
					.removeSidebarToggle { window in
						window.toolbarStyle = .unified
					}
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
				UserSettings(user: user).tabItem {
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

		@State private var showingDetail = false

		private struct Page: Hashable, Identifiable {
			internal init(_ name: Name, icon: Icon? = nil, showName: Bool = true, children: [SettingsView.ModernSettings.Page] = []) {
				self.children = children
				self.name = name
				self.icon = icon
				self.showName = showName
			}

			var id: String { name.rawValue }

			let showName: Bool

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
				case userProfileSection = "Profile"
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
				// MARK: Misc
				case miscSection = "Misc"
				case about = "About"
				case credits = "Credits"
				// MARK: Developer
				case devSection = "Dev"
				case advanced = "settings.app.advanced"
				case diag = "Diagnostics"
			}
		}
		private static let pages: [Page] = [
			Page(.userProfileSection, showName: false, children: [
				Page(.account, icon: .init(baseColor: .blue, icon: .system("person.fill")))
			]),
			Page(.userSection, children: [
				Page(.profile, icon: .init(baseColor: .blue, icon: .system("person.crop.circle"))),
				Page(.privacy, icon: .init(baseColor: .red, icon: .system("shield.lefthalf.filled")))
			]),
			Page(.paymentSection, children: [
				Page(.nitro, icon: .init(baseColor: .white, icon: .asset("NitroSubscriber"))),
				Page(.boost, icon: .init(baseColor: .init("NitroPink"), icon: .asset("ServerBoost"))),
				Page(.subscriptions, icon: .init(baseColor: .purple, icon: .system("wallet.pass.fill"))),
				Page(.gift, icon: .init(baseColor: .purple, icon: .system("gift.fill"))),
				Page(.billing, icon: .init(baseColor: .purple, icon: .system("creditcard.fill")))
			]),
			Page(.appSection, children: [
				Page(.appearance, icon: .init(baseColor: .black, icon: .system("circle.lefthalf.filled"))),
				Page(.accessibility, icon: .init(baseColor: .blue, icon: .system("figure.wave.circle"))),
				Page(.voiceVideo, icon: .init(baseColor: .red, icon: .system("waveform"))),
				Page(.textImages, icon: .init(baseColor: .red, icon: .system("text.below.photo.fill"))),
				Page(.notifs, icon: .init(baseColor: .blue, icon: .system("bell.badge.fill"))),
				Page(.keybinds, icon: .init(baseColor: .blue, icon: .system("keyboard.fill"))),
				Page(.lang, icon: .init(baseColor: .blue, icon: .system("globe"))),
				Page(.streamer, icon: .init(baseColor: .blue, icon: .system("camera.on.rectangle.fill")))
			]),
			Page(.miscSection, showName: false, children: [
				Page(.about, icon: .init(baseColor: .gray, icon: .system("info"))),
				Page(.credits, icon: .init(baseColor: .gray, icon: .system("person.2.fill")))
			]),
			Page(.devSection, showName: false, children: [
				Page(.advanced, icon: .init(baseColor: .gray, icon: .system("hammer.fill"))),
				Page(.diag, icon: .init(baseColor: .gray, icon: .system("wrench.adjustable.fill")))
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
										Image(name).resizable().aspectRatio(contentMode: .fit).padding(2)
									}
								}
								.foregroundColor(.white)
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
					if category.showName {
						Section(category.nameString) {
							ForEach(category.children) { child in
								navigationItem(item: child)
							}
						}
					} else {
						Section {
							ForEach(category.children) { child in
								navigationItem(item: child)
							}
						}
					}
				}
				.navigationSplitViewColumnWidth(215)
			} detail: {
				ScrollView {
					Form {
						switch selectedPage.name {
						// MARK: User Settings
						case .account:
							AccountOverview(user: user)
						case .profile:
							UserSettingsProfileView(user: user)
						case .privacy:
							UserSettingsPrivacySafetyView()

						// MARK: App Settings
						case .appearance:
							AppSettingsAppearanceView()
						case .accessibility:
							AppSettingsAccessibilityView()

						// MARK: Misc
						case .about:
							AboutSwiftcordView()
						case .credits:
							CreditsView()
						// MARK: Developer
						case .advanced:
							AppSettingsAdvancedView()
						case .diag:
							DebugSettingsView()
						default:
							// Concatenate texts so LocalizedStrings work
							Text("Unimplemented view: ") + Text(selectedPage.nameString)
						}
					}
					.formStyle(.grouped)
				}
				.navigationSplitViewColumnWidth(500)
				.removeSidebarToggle()
				.onAppear {
					showingDetail = false
				}
				.onDisappear {
					showingDetail = true
				}
			}
			.searchable(text: $filter, placement: .sidebar)
			.navigationTitle(selectedPage.nameString)
			.toolbar {
				ToolbarItem(placement: .navigation) {
					if !showingDetail {
						Rectangle()
							.frame(width: 10)
							.opacity(0)
					} else {
						EmptyView()
					}
				}
			}
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
