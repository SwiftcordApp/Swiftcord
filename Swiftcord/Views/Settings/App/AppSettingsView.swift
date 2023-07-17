//
//  AppSettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI

struct AppSettingsView: View {
	@State private var selectedLink: SidebarLink.ID? = SidebarLink.appearance.id

  var body: some View {
    if #available(macOS 14, *) {
      createNav()
    } else {
      createOldNav()
    }
  }
}

extension AppSettingsView
{
	@available(macOS 14, *)
	@ViewBuilder func createNav() -> some View
	{
		NavigationSplitView {
			List(SidebarLink.allCases, selection: $selectedLink) { setting in
				Label(setting.name, systemImage: setting.icon)
			}
		} detail: {
			ScrollView { SidebarLink.allCases.filter({ $0.id == selectedLink }).first?.makeView().padding(40) }
		}
    .onAppear {
      AnalyticsWrapper.event(type: .settingsPaneViewed, properties: [
        "origin_pane": selectedLink ?? "",
      ])
    }
    .onChange(of: selectedLink) { [selectedLink] newSelection in
      AnalyticsWrapper.event(type: .settingsPaneViewed, properties: [
        "destination_pane": newSelection ?? "",
        "origin_pane": selectedLink ?? "",
      ])
    }
	}
	
	@available(macOS, deprecated: 14, obsoleted: 14, message: "Please use ``createNav`` on macOS 14 and above.")
	@ViewBuilder func createOldNav() -> some View
	{
		NavigationView {
			List(SidebarLink.allCases, selection: $selectedLink) { setting in
				NavigationLink(setting.icon, tag: setting.id, selection: $selectedLink) {
					ScrollView { SidebarLink.allCases.filter({ $0.id == selectedLink }).first?.makeView().padding(40) }
				}
			}
		}
		.listStyle(SidebarListStyle())
		.onAppear {
			AnalyticsWrapper.event(type: .settingsPaneViewed, properties: [
				"origin_pane": selectedLink ?? ""
			])
		}
		.onChange(of: selectedLink) { [selectedLink] newSelection in
			AnalyticsWrapper.event(type: .settingsPaneViewed, properties: [
				"destination_pane": newSelection ?? "",
				"origin_pane": selectedLink ?? ""
			])
		}
	}
}

private extension AppSettingsView {
	// Raw values are for analytics events
	enum SidebarLink: String, CaseIterable, Identifiable {
		var id: String { rawValue }
		
		case appearance
		case accessibility
		case voiceVideo
		case textImages
		case notifs
		case keybinds
		case lang
		case streamer
		case advanced

    var name: String {
      switch self {
        case .appearance: return "Appearance"
        case .accessibility: return "Accessibility"
        case .voiceVideo: return "Voice & Video"
        case .textImages: return "Text & Images"
        case .notifs: return "Notifications"
        case .keybinds: return "Keybinds"
        case .lang: return "Language"
        case .streamer: return "Streamer Mode"
        case .advanced: return "Advanced"
      }
    }

    var icon: String {
      return "settings.app.\(self.rawValue)"
    }

    @ViewBuilder func makeView() -> some View {
      switch self {
        case .appearance: AppSettingsAppearanceView()
        case .accessibility: AppSettingsAccessibilityView()
        case .voiceVideo: Text("")
        case .textImages: Text("")
        case .notifs: Text("")
        case .keybinds: Text("")
        case .lang: Text("")
        case .streamer: Text("")
        case .advanced: AppSettingsAdvancedView()
      }
    }
	}
}
