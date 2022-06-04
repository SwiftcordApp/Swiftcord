//
//  MiscSettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI

struct MiscSettingsView: View {
	@State private var selectedLink: SidebarLink? = .changelog

    var body: some View {
        NavigationView {
			List {
				NavigationLink("Change Log", tag: SidebarLink.changelog, selection: $selectedLink) {
                    Text("Nothing")
                }

				NavigationLink("Hypesquad", tag: SidebarLink.hype, selection: $selectedLink) {
                    Text("Not hype")
                }

				NavigationLink("About", tag: SidebarLink.about, selection: $selectedLink) {
                    AboutSwiftcordView()
                }

				NavigationLink("Debug", tag: SidebarLink.debug, selection: $selectedLink) {
                    DebugSettingsView()
                }
            }.listStyle(SidebarListStyle())
        }
    }
}

private extension MiscSettingsView {
	enum SidebarLink {
		case changelog
		case hype
		case about
		case debug
	}
}
