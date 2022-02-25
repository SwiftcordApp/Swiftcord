//
//  UserAvatarView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI

struct UserAvatarView: View {
    let user: User
    let guildID: Snowflake
    @State private var profile: UserProfile? = nil // Lazy-loaded full user
    @State private var guildRoles: [Role]? = nil // Lazy-loaded guild roles
    @State private var infoPresenting = false
    @State private var note = ""
    
    var body: some View {
        let avatarURL = URL(string: user.avatar != nil
            ? "\(apiConfig.cdnURL)avatars/\(user.id)/\(user.avatar!).webp"
            : "\(apiConfig.cdnURL)embed/avatars/\(Int(user.discriminator) ?? 0 % 5).png"
        )
        AsyncImage(url: avatarURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            ProgressView().progressViewStyle(.circular)
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
        .onTapGesture {
            // Get user profile for a fuller User object
            if profile == nil { Task {
                profile = await DiscordAPI.getProfile(user: user.id, guildID: guildID)
                guard profile != nil else { // Profile is still nil: fetching failed
                    return
                }
                // print(profile)
            }}
            if guildRoles == nil { Task {
                guildRoles = await DiscordAPI.getGuildRoles(id: guildID)
                print(guildRoles)
            }}
            infoPresenting.toggle()
        }
        .popover(isPresented: $infoPresenting, arrowEdge: .trailing) {
            VStack(alignment: .leading, spacing: 0) {
                if (profile?.user.accent_color ?? user.accent_color) != nil {
                    Rectangle().fill(Color(hex: profile?.user.accent_color ?? user.accent_color ?? 0))
                        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                }
                else {
                    AsyncImage(url: avatarURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: { ProgressView().progressViewStyle(.circular)}
                    .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                        .blur(radius: 8)
                        .clipped()
                }
                ZStack {
                    Circle()
                        .trim(from: 0.5, to: 1)
                        .fill(.black)
                        .frame(width: 92, height: 92)
                    AsyncImage(url: avatarURL) { image in
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
                
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .bottom, spacing: 0) {
                        Text(user.username)
                            .font(.title)
                            .fontWeight(.medium)
                            .textSelection(.enabled)
                        Text("#\(user.discriminator)").font(.title3)
                    }
                    
                    Divider()
                    
                    if profile == nil {
                        ProgressView("Loading full profile...")
                            .progressViewStyle(.linear)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Optionals are silly
                    if (profile?.user.bio) != nil
                        && !(profile?.user.bio!.isEmpty ?? false) {
                        Text("ABOUT ME").font(.headline)
                        Text((profile?.user.bio)!)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    if profile != nil {
                        if guildRoles == nil {
                            ProgressView("Loading roles...")
                                .progressViewStyle(.linear)
                                .frame(maxWidth: .infinity)
                        } else {
                            let roles = guildRoles!.filter({ r in
                                profile!.guild_member!.roles.contains(r.id)
                            })
                            
                            Text(roles.isEmpty
                                 ? "NO ROLES"
                                 : (roles.count == 1 ? "ROLE" : "ROLES")
                            ).font(.headline).padding(.top, 2)
                            if !roles.isEmpty {
                                TagCloudView(content: roles.map({ role in
                                    AnyView(
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
                                        .cornerRadius(20)
                                    )
                                })).padding(.vertical, -2)
                            }
                        }
                    }
                    
                    Text("NOTE").font(.headline).padding(.top, 2)
                    // Notes are stored locally for now, but eventually will be synced with the Discord API
                    TextField("Add a note to this user (only visible to you)", text: $note)
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
