//
//  PreferencesView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/3/22.
//

import SwiftUI
 
struct PrivacySettingsView: View {
    var body: some View {
        Text("Privacy Settings")
            .font(.title)
    }
}
 

struct SettingsView: View {
    var body: some View {
        TabView {
            UserSettingsView().tabItem { Label("User", systemImage: "person.crop.circle") }
               
            BillingSettingsView().tabItem {
                Label("Billing", systemImage: "dollarsign.circle")
            }
           
            AppSettingsView().tabItem {
                Label("App", systemImage: "macwindow")
            }
            
            ActivitySettingsView().tabItem {
                Label("Activity", systemImage: "hammer")
            }
            
            MiscSettingsView().tabItem {
                Label("Misc", systemImage: "ellipsis")
            }
        }
        .frame(width: 900, height: 600)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
