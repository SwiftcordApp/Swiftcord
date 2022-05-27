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
                NavigationLink("Appearance") {
                    Text("Don't get nitro, nitro bad")
                }

                NavigationLink("Accessibility") {
                    Text("")
                }

                NavigationLink("Voice & Video") {
                    Text("The 2 biggest pain points")
                }

                NavigationLink("Text & Images") {
                    Text("")
                }

                NavigationLink("Notifications") {
                    Text("Cue Discord ping sound")
                }

                NavigationLink("Keybinds") {
                    Text("")
                }

                NavigationLink("Language") {
                    Text("")
                }

                NavigationLink("Streamer Mode") {
                    Text("")
                }

                NavigationLink("Advanced") {
                    Text("")
                }
            }.listStyle(SidebarListStyle())
        }
    }
}
