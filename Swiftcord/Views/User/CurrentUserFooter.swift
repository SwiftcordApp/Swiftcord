//
//  CurrentUserFooter.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/3/22.
//
//

import SwiftUI
import CachedAsyncImage
import DiscordKit

struct CurrentUserFooter: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                let avatarURL = user.avatarURL()
                CachedAsyncImage(url: avatarURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView().progressViewStyle(.circular)
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            }.padding(.leading, 8)
            VStack(alignment: .leading, spacing: 0) {
                Text(user.username).font(.headline)
                Text("#" + user.discriminator).font(.system(size: 12)).opacity(0.75)
            }
            Spacer()
            Button(action: {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }, label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .opacity(0.75)
            }).buttonStyle(.plain)
            .padding(.trailing, 14)
        }
        .frame(height: 52)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
}

struct CurrentUserFooter_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
