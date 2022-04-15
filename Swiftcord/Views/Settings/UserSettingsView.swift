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
                .foregroundColor(.accentColor)
            
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
                    VStack(alignment: .leading, spacing: 4) {
                        Text("USERNAME").font(.headline).opacity(0.75)
                        Group {
                            Text(user.username) + Text("#" + user.discriminator).foregroundColor(Color(NSColor.textColor).opacity(0.75))
                        }
                        .font(.system(size: 16))
                        .textSelection(.enabled)
                        
                        Divider().padding(.vertical, 10)
                        
                        Text("EMAIL").font(.headline).opacity(0.75)
                        Text(user.email ?? "No email")
                            .font(.system(size: 16))
                            .textSelection(.enabled)
                        
                        Divider().padding(.vertical, 10)
                        
                        Text("PHONE NUMBER").font(.headline).opacity(0.75)
                        Text("Retrieving phone number isn't implemented yet")
                            .font(.system(size: 16))
                            .textSelection(.enabled)
                    }.padding(10).frame(maxWidth: .infinity)
                }
            }
            
            Group {
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
                }) { changePwDialog }
                
                Text("TWO-FACTOR AUTHENTHICATION" + ((user.mfa_enabled ?? false) ? " ENABLED" : ""))
                    .font(.headline)
                    .foregroundColor((user.mfa_enabled ?? false) ? .green : nil)
                    .padding(.top, 12)
                Text("Two-Factor authentication (2FA for short) is a good way to add an extra layer of security to your Discord account to make sure that only you have the ability to log in.")
                    .opacity(0.75)
                    .padding(.top, -8)
                
                
                HStack(spacing: 16) {
                    Button("View Backup Codes") {
                        
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    Button("Remove 2FA", role: .destructive) {
                        
                    }
                    .controlSize(.large)
                }
            }
            
            Group {
                Divider().padding(.vertical, 16)
                
                Text("ACCOUNT REMOVAL")
                    .font(.headline)
                Text("Disabling your account means you can recover it at any time after taking this action.")
                    .opacity(0.75)
                    .padding(.top, -8)
                HStack(spacing: 16) {
                    Button("Disable Account", role: .destructive) {
                        
                    }
                    .tint(.red)
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    Button("Delete Account", role: .destructive) {
                        
                    }
                    .controlSize(.large)
                }
            }
            
            Spacer()
        }
    }
}

struct UserSettingsView: View {
    let user: User
    
    @AppStorage("userSettingsSelected") private var selectedLink = "acct"
    @EnvironmentObject var gateway: DiscordGateway
    
    var body: some View {        
        NavigationView {
            List {
                NavigationLink("My Account", tag: "acct", selection: Binding($selectedLink)) {
                    ScrollView { UserSettingsAccountView(user: user).padding(40) }
                }
                
                NavigationLink("User Profile", tag: "profile", selection: Binding($selectedLink)) {
                    Text("")
                }
                
                NavigationLink("Privacy & Safety", tag: "privacy", selection: Binding($selectedLink)) {
                    Text("")
                }
                
                NavigationLink("Authorized Apps", tag: "apps", selection: Binding($selectedLink)) {
                    Text("")
                }
                                
                NavigationLink("Connections", tag: "conns", selection: Binding($selectedLink)) {
                    Text("")
                }
                
                NavigationLink("Log Out", tag: "logOut", selection: Binding($selectedLink)) {
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
