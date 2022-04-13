//
//  ChannelButton.swift
//  Swiftcord
//
//  Created by Vincent on 4/13/22.
//

import SwiftUI

let chIcons = [
    ChannelType.voice: "speaker.wave.2.fill",
    .news: "megaphone.fill",
]

struct ChannelButton: View {
    let channel: Channel
    let guild: Guild?
    @Binding var selectedCh: Channel?
    
    var body: some View {
        Button {
            selectedCh = channel
            UserDefaults.standard.setValue(channel.id, forKey: "guildLastCh.\(guild!.id)")
        } label: {
            Label(
                channel.name ?? "",
                systemImage: (guild?.rules_channel_id != nil && guild?.rules_channel_id! == channel.id) ? "newspaper.fill" : (chIcons[channel.type] ?? "number")
            ).frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.borderedProminent)
        .accentColor(Color.gray)
    }
}
