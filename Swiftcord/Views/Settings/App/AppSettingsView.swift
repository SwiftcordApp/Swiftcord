//
//  AppSettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI

struct AppSettingsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("settings.app.appearance") {
                    Text("")
                }

                NavigationLink("settings.app.accessibility") {
                    Text("")
                }

                NavigationLink("settings.app.voiceVideo") {
                    Text("")
                }

                NavigationLink("settings.app.textImages") {
                    Text("")
                }

                NavigationLink("settings.app.notifs") {
                    Text("")
                }

                NavigationLink("settings.app.keybinds") {
                    Text("")
                }

                NavigationLink("settings.app.lang") {
                    Text("")
                }

                NavigationLink("settings.app.streamer") {
                    Text("")
                }

                NavigationLink("settings.app.advanced") {
                    Text("")
                }
            }.listStyle(SidebarListStyle())
        }
    }
}
