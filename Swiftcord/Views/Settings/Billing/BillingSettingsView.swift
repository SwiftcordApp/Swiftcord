//
//  BillingSettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI

struct BillingSettingsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Discord Nitro") {
                    Text("Don't get nitro, nitro bad")
                }

                NavigationLink("Server Boost") {
                    Text("")
                }

                NavigationLink("Subscriptions") {
                    Text("")
                }

                NavigationLink("Gift Inventory") {
                    Text("")
                }

                NavigationLink("Billing") {
                    Text("$$$ 💸")
                }
            }.listStyle(SidebarListStyle())
        }
    }
}
