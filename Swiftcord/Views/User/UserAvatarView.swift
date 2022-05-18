//
//  UserAvatarView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import CachedAsyncImage
import DiscordKit

struct UserAvatarView: View {
    let user: User
    let guildID: Snowflake
    let webhookID: Snowflake?
    let clickDisabled: Bool
    @State private var profile: UserProfile? = nil // Lazy-loaded full user
    @State private var guildRoles: [Role]? = nil // Lazy-loaded guild roles
    @State private var infoPresenting = false
    @State private var note = ""
    @State private var loadFullFailed = false
    
    var body: some View {
        let avatarURL = user.avatarURL()
        CachedAsyncImage(url: avatarURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            ProgressView().progressViewStyle(.circular)
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
        .onTapGesture {
            guard !clickDisabled else { return }
            // Get user profile for a fuller User object
            if profile == nil && webhookID == nil { Task {
                profile = await DiscordAPI.getProfile(user: user.id, guildID: guildID)
                guard profile != nil else { // Profile is still nil: fetching failed
                    loadFullFailed = true
                    return
                }
            }}
            if guildRoles == nil && webhookID == nil { Task {
                guildRoles = await DiscordAPI.getGuildRoles(id: guildID)
                // print(guildRoles)
            }}
            infoPresenting.toggle()
        }
        .cursor(NSCursor.pointingHand)
        .popover(isPresented: $infoPresenting, arrowEdge: .trailing) {
            VStack(alignment: .leading, spacing: 0) {
                if let accentColor = profile?.user.accent_color ?? user.accent_color {
                    Rectangle().fill(Color(hex: accentColor))
                        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                }
                else {
                    CachedAsyncImage(url: avatarURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: { ProgressView().progressViewStyle(.circular)}
                    .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                        .blur(radius: 4)
                        .clipped()
                }
                ZStack {
                    Circle()
                        .trim(from: 0.5, to: 1)
                        .fill(.black)
                        .frame(width: 92, height: 92)
                    CachedAsyncImage(url: avatarURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView().progressViewStyle(.circular)
                    }
                    .background(.black)
                    .clipShape(Circle())
                    .frame(width: 80, height: 80)
                }
                .offset(x: 14)
                .padding(.top, -46)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 0) {
                        Text(user.username)
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        // Webhooks don't have discriminators
                        if webhookID == nil {
                            Text("#\(user.discriminator)")
                                .font(.title2)
                                .opacity(0.7)
                        }
                        Spacer()
                        if loadFullFailed {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                                .help("Failed to get full user profile")
                        }
                    }
                    .padding(.bottom, -2)
                    .padding(.top, -8)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    if webhookID != nil {
                        Text("This user is a webhook")
                        Button {
                            
                        } label: {
                            Label("Manage Server Webhooks", systemImage: "link")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    } else {
                        if profile == nil && !loadFullFailed {
                            ProgressView("Loading full profile...")
                                .progressViewStyle(.linear)
                                .frame(maxWidth: .infinity)
								.tint(.blue)
                        }
                        
                        // Optionals are silly
						if let bio = profile?.user.bio, !bio.isEmpty {
                            Text("ABOUT ME")
								.font(.headline)
                            Text(bio)
                                .fixedSize(horizontal: false, vertical: true)
                        } else if profile != nil {
                            Text("NO ABOUT").font(.headline)
                        }
                        
                        if let profile = profile {
                            if let guildRoles = guildRoles {
                                let roles = guildRoles.filter({ r in
                                    profile.guild_member!.roles.contains(r.id)
                                })
                                
                                Text(roles.isEmpty
                                     ? "NO ROLES"
                                     : (roles.count == 1 ? "ROLE" : "ROLES")
                                ).font(.headline).padding(.top, 8)
                                if !roles.isEmpty {
                                    TagCloudView(content: roles.map({ role in
										HStack(spacing: 6) {
											Circle()
												.fill(Color(hex: role.color))
												.frame(width: 14, height: 14)
												.padding(.leading, 6)
											Text(role.name)
												.font(.system(size: 12))
												.padding(.trailing, 8)
										}
										.frame(height: 24)
										.background(Color.gray.opacity(0.2))
										.cornerRadius(7)
                                    })).padding(-2)
                                }
							} else {
								ProgressView("Loading roles...")
									.progressViewStyle(.linear)
									.frame(maxWidth: .infinity)
									.tint(.blue)
							}
                        }
                        
                        Text("NOTE").font(.headline).padding(.top, 8)
                        // Notes are stored locally for now, but eventually will be synced with the Discord API
                        TextField("Add a note to this user (only visible to you)", text: $note)
							.textFieldStyle(.roundedBorder)
                            .onChange(of: note) { _ in
                                if note.isEmpty {
                                    UserDefaults.standard.removeObject(forKey: "notes.\(user.id)")
                                }
                                else {
                                    UserDefaults.standard.set(note, forKey: "notes.\(user.id)")
                                }
                            }
                            .onAppear {
                                note = UserDefaults.standard.string(forKey: "notes.\(user.id)") ?? ""
                            }
                    }
                }
                .padding(14)
            }.frame(width: 300)
        }
    }
}

struct UserAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        // UserAvatarView()
        Text("TODO")
    }
}
