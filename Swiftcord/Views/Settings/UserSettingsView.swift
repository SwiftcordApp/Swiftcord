//
//  UserSettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI

struct UserSettingsAccountView: View {
    let user: User
    
    @State private var changePwSheetShown = false
    @State private var oldPw = ""
    @State private var newPw = ""
    
    var changePwDialog: some View {
        VStack(spacing: 4) {
            Image(systemName: "lock")
                .font(.system(size: 30))
                .foregroundColor(Color("DiscordTheme"))
            
            Text("Change your password")
                .font(.title)
                .padding(.top, 4)
            Text("Enter your current password and a new one.")
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("CURRENT PASSWORD").font(.headline).opacity(0.75).padding(.top, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            SecureField("Current password", text: $oldPw, prompt: Text("Enter your existing password"))
                .textFieldStyle(.roundedBorder)
            
            Text("NEW PASSWORD").font(.headline).opacity(0.75).padding(.top, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            SecureField("New password", text: $newPw, prompt: Text("Enter a new password"))
                .textFieldStyle(.roundedBorder)
            
            Text("CONFIRM NEW PASSWORD").font(.headline).opacity(0.75).padding(.top, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            SecureField("Confirm new password", text: $newPw, prompt: Text("Reenter your new password"))
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Button(action: { changePwSheetShown = false }) {
                    Text("Close")
                }
                .controlSize(.large)
                .buttonStyle(.bordered)
                Spacer()
                Button(action: { changePwSheetShown = false }) {
                    Text("Done")
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 16)
        }
        .padding(16)
        .frame(width: 408)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Profile").font(.title)
            LargeUserProfile(user: user) {
                GroupBox {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("USERNAME").font(.headline).opacity(0.75)
                        Group {
                            Text(user.username) + Text("#" + user.discriminator).foregroundColor(Color(NSColor.textColor).opacity(0.75))
                        }
                        .font(.system(size: 16))
                        .textSelection(.enabled)
                        
                        Divider().padding(.vertical, 12)
                        
                        Text("EMAIL").font(.headline).opacity(0.75)
                        Text(user.email ?? "No email")
                            .font(.system(size: 16))
                            .textSelection(.enabled)
                        
                        Divider().padding(.vertical, 12)
                        
                        Text("PHONE NUMBER").font(.headline).opacity(0.75)
                        Text("Retrieving phone number isn't implemented yet")
                            .font(.system(size: 16))
                            .textSelection(.enabled)
                    }.padding(10).frame(maxWidth: .infinity)
                }
            }
            
            Divider().padding(.vertical, 16)
            
            Text("Password and Authenthication").font(.title)
            Button(action: { changePwSheetShown = true }) {
                Text("Change Password")
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $changePwSheetShown, onDismiss: {
                oldPw = ""
                newPw = ""
            }) {
                
            }
            
            Spacer()
        }
    }
}

struct UserSettingsView: View {
    @EnvironmentObject var gateway: DiscordGateway
    
    var body: some View {
        let user = gateway.cache.user!
        
        NavigationView {
            List {
                NavigationLink("My Account") {
                    ScrollView { UserSettingsAccountView(user: user).padding(40) }
                }
                
                NavigationLink("User Profile") {
                    Text("")
                }
                
                NavigationLink("Privacy & Safety") {
                    Text("")
                }
                
                NavigationLink("Authorized Apps") {
                    Text("")
                }
                                
                NavigationLink("Connections") {
                    Text("")
                }
                
                NavigationLink("Log Out") {
                    VStack {
                        Text("Log Out").font(.title)
                        
                    }
                }
                Button(role: .destructive) {
                    gateway.logOut()
                } label: {
                    Label("Log Out", systemImage: "arrow.turn.up.left")
                }

            }.listStyle(SidebarListStyle())
        }
    }
}
