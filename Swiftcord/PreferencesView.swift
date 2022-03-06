//
//  PreferencesView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/3/22.
//

import SwiftUI

struct ProfileSettingsView: View {
    var body: some View {
        Text("Profile Settings")
            .font(.title)
    }
}
 
 
struct AppearanceSettingsView: View {
    var body: some View {
        Text("Appearance Settings\ndlskflkasdfokdasf\nwjfoiewjoifjweof\nsfwe")
            .font(.title)
    }
}
 
 
struct PrivacySettingsView: View {
    var body: some View {
        Text("Privacy Settings")
            .font(.title)
    }
}
 

struct PreferencesView: View {
    var body: some View {
        TabView {
            ProfileSettingsView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
               
            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintpalette")
                }
           
            PrivacySettingsView()
                .tabItem {
                    Label("Privacy", systemImage: "hand.raised")
                }
        }
        .frame(width: 450)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
