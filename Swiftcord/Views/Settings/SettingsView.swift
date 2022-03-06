//
//  PreferencesView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/3/22.
//

import SwiftUI

struct ProfileSettingsView: View {
    private let dummyList = ["test", "Another test", "lol"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dummyList, id: \.self) { item in
                    NavigationLink(item) {
                        Text("This is the \(item) item")
                    }
                }
            }.listStyle(SidebarListStyle())
        }
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
 

struct SettingsView: View {
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
        .frame(width: 900, height: 600)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
