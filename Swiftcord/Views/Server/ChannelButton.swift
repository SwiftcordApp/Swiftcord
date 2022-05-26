//
//  ChannelButton.swift
//  Swiftcord
//
//  Created by Vincent on 4/13/22.
//

import SwiftUI
import DiscordKit
import CachedAsyncImage

struct ChannelButton: View {
    let channel: Channel
    let guild: Guild?
    @Binding var selectedCh: Channel?
    
    var body: some View {
		if channel.type == .dm || channel.type == .groupDM {
			DMButton(dm: channel, selectedCh: $selectedCh)
				.buttonStyle(DiscordChannelButton(isSelected: selectedCh?.id == channel.id))
		} else {
			GuildChButton(ch: channel, guild: guild, selectedCh: $selectedCh)
				.buttonStyle(DiscordChannelButton(isSelected: selectedCh?.id == channel.id))
		}
    }
}

struct GuildChButton: View {
	let ch: Channel
	let guild: Guild?
	@Binding var selectedCh: Channel?
	
	private let chIcons = [
		ChannelType.voice: "speaker.wave.2.fill",
		.news: "megaphone.fill",
	]
	
	var body: some View {
		Button {
			selectedCh = ch
			UserDefaults.standard.setValue(ch.id.description, forKey: "guildLastCh.\(guild!.id.description)")
		} label: {
			let image = (guild?.rules_channel_id != nil && guild?.rules_channel_id! == ch.id) ? "newspaper.fill" : (chIcons[ch.type] ?? "number")
			Label(ch.label() ?? "nil", systemImage: image)
				.padding(.vertical, 6)
				.padding(.horizontal, 2)
				.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
}

struct DMButton: View {
	let dm: Channel
	@Binding var selectedCh: Channel?
	
	@EnvironmentObject var gateway: DiscordGateway
	
	var body: some View {
		Button {
			selectedCh = dm
		} label: {
			HStack {
				if dm.type == .dm,
				   let avatarURL = gateway.cache.users[dm.recipient_ids![0]]?.avatarURL(size: 64) {
					CachedAsyncImage(url: avatarURL) { image in
						image.resizable().scaledToFill()
					} placeholder: { Rectangle().fill(.gray.opacity(0.2)) }
					.frame(width: 32, height: 32)
					.clipShape(Circle())
				} else {
					Image(systemName: "person.2.fill")
						.foregroundColor(.white)
						.frame(width: 32, height: 32)
						.background(.red)
						.clipShape(Circle())
				}
				
				VStack(alignment: .leading, spacing: 2) {
					Text(dm.label(gateway.cache.users) ?? "nil")
					if dm.type == .groupDM {
						Text("\((dm.recipient_ids?.count ?? 2) + 1) Members").font(.caption)
					}
				}
				Spacer()
			}
			.padding(.horizontal, 6)
			.padding(.vertical, 5)
		}
	}
}

struct DiscordChannelButton: ButtonStyle {
	let isSelected: Bool
	@State var isHovered: Bool = false
	
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.buttonStyle(.borderless)
			.font(.system(size: 14, weight: isSelected ? .medium : .regular))
			.foregroundColor(isSelected ? Color(nsColor: .labelColor) : .gray)
			.accentColor(isSelected ? Color(nsColor: .labelColor) : .gray)
			.background(
				RoundedRectangle(cornerRadius: 4)
					.fill(isSelected ? .gray.opacity(0.3) : (isHovered ? .gray.opacity(0.2) : .clear))
            )
            .onHover(perform: { isHovered = $0 })
    }
}
