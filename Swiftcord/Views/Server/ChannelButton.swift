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
        .buttonStyle(DiscordChannelButton(isSelected: Binding<Bool>(get: {selectedCh?.id == channel.id}, set: { _ in })))
    }
}

struct DiscordChannelButton: ButtonStyle {
    @Binding var isSelected: Bool
    @State var isHovered: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, -4)
            .buttonStyle(.borderless)
            .font(.system(size: 14))
            .accentColor(Color.gray) // makes sf symbol gray
            .padding(.vertical, 6)
            .foregroundColor(isSelected ? .white : .gray)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? .gray.opacity(0.3) : (isHovered ? .gray.opacity(0.2) : .clear))
                    .padding(.horizontal, -8)
            )
            .onHover(perform: { over in isHovered = over })
    }
}
