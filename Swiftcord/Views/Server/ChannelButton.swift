//
//  ChannelButton.swift
//  Swiftcord
//
//  Created by Vincent on 4/13/22.
//

import SwiftUI
import DiscordKit

struct ChannelButton: View {
    let channel: Channel
    let guild: Guild?
    @Binding var selectedCh: Channel?

	let chIcons = [
		ChannelType.voice: "speaker.wave.2.fill",
		.news: "megaphone.fill",
	]
    
    var body: some View {
        Button {
            selectedCh = channel
			UserDefaults.standard.setValue(channel.id.description, forKey: "guildLastCh.\(guild!.id.description)")
        } label: {
			let image = (guild?.rules_channel_id != nil && guild?.rules_channel_id! == channel.id) ? "newspaper.fill" : (chIcons[channel.type] ?? "number")
            Label(channel.label ?? "", systemImage: image)
				.frame(maxWidth: .infinity, alignment: .leading)
        }
		.buttonStyle(DiscordChannelButton(isSelected: .constant(selectedCh?.id == channel.id)))
    }
}

struct DiscordChannelButton: ButtonStyle {
    @Binding var isSelected: Bool
    @State var isHovered: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, -4)
            .buttonStyle(.borderless)
            .font(.system(size: 14, weight: isSelected ? .medium : .regular))
            .padding(.vertical, 6)
			.foregroundColor(isSelected ? Color(nsColor: .labelColor) : .gray)
			.accentColor(isSelected ? Color(nsColor: .labelColor) : .gray)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? .gray.opacity(0.3) : (isHovered ? .gray.opacity(0.2) : .clear))
                    .padding(.horizontal, -8)
            )
            .onHover(perform: { isHovered = $0 })
    }
}
