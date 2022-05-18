//
//  UserSettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI
import DiscordKit

struct UserSettingsView: View {
    let user: User
    
	@State private var selectedLink: SidebarLink? = .account
    @EnvironmentObject var gateway: DiscordGateway
    
    var body: some View {        
        NavigationView {
            List {
				NavigationLink("My Account", tag: SidebarLink.account, selection: $selectedLink) {
                    ScrollView { UserSettingsAccountView(user: user).padding(40) }
                }
                
				NavigationLink("User Profile", tag: SidebarLink.profile, selection: $selectedLink) {
                    Text("")
                }
                
				NavigationLink("Privacy & Safety", tag: SidebarLink.privacy, selection: $selectedLink) {
                    Text("")
                }
                
				NavigationLink("Authorized Apps", tag: SidebarLink.apps, selection: $selectedLink) {
                    Text("")
                }
                                
				NavigationLink("Connections", tag: SidebarLink.connections, selection: $selectedLink) {
                    Text("")
                }
                
				NavigationLink("Log Out", tag: SidebarLink.logOut, selection: $selectedLink) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Log Out").font(.title)
                        Text("Are you sure you want to log out?")
                        Button(role: .destructive) {
                            gateway.logout()
                        } label: {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        
                        Spacer()
                    }
                    .padding(40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }.listStyle(SidebarListStyle())
        }
    }
}

private extension UserSettingsView {
	enum SidebarLink {
		case account
		case profile
		case privacy
		case apps
		case connections
		case logOut
	}
}
