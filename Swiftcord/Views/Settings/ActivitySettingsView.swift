//
//  ActivitySettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI

struct ActivitySettingsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Activity Status") {
                    Text("What are you doing with your life?")
                }
            }.listStyle(SidebarListStyle())
        }
    }
}
