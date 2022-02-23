//
//  UserAvatarView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI

// Create color with hex int
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct UserAvatarView: View {
    let user: User
    @State private var fullUser: User? = nil // Lazy-loaded full user
    @State private var infoPresenting = false
    
    var body: some View {
        let avatarURL = URL(string: user.avatar != nil
            ? "\(apiConfig.cdnURL)avatars/\(user.id)/\(user.avatar!).webp"
            : "\(apiConfig.cdnURL)embed/avatars/\(Int(user.discriminator) ?? 0 % 5).png"
        )
        AsyncImage(url: avatarURL) { image in image.resizable()} placeholder: {
            ProgressView().progressViewStyle(.circular)
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
        .onTapGesture {
            if fullUser == nil { Task {
                fullUser = await DiscordAPI.getUser(user: user.id)
            }}
            infoPresenting.toggle()
        }
        .popover(isPresented: $infoPresenting, arrowEdge: .trailing) {
            VStack(alignment: .leading, spacing: 0) {
                if (fullUser?.accent_color ?? user.accent_color) != nil {
                    Rectangle().fill(Color(hex: UInt(fullUser?.accent_color ?? user.accent_color ?? 0)))
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                else {
                    AsyncImage(url: avatarURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: { ProgressView().progressViewStyle(.circular)}
                        .frame(maxWidth: .infinity, minHeight: 60)
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
                .offset(x: 14, y: -46)
                
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .bottom, spacing: 0) {
                        Text(user.username).font(.title)
                        Text("#\(user.discriminator)").font(.title3)
                    }
                    
                    Divider()
                    Text("ABOUT ME").font(.headline)
                    Text("This is just filler text, currently fetching user's about is not yet supported because it has to be received from the Gateway")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("ROLES").font(.headline).padding(.top, 2)
                }
                .padding(.top, 10)
                .padding([.trailing, .leading], 14)
                .offset(y: -46)
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
