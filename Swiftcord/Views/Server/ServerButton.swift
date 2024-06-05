//
//  ServerButton.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 22/2/22.
//

import SwiftUI
import DiscordKit
import DiscordKitCore
import CachedAsyncImage

/*
 Font size of text in server button for servers without an icon

 # of chars	 Font size (px)
 1			 18
 2			 18
 3		 	 16
 4			 16
 5		 	 14
 6			 12
 7			 10
 8			 10
 9			 10
 10			 10
 */

struct ServerButton: View {
	let selected: Bool
	var guild: PreloadedGuild?
	let name: String
	var systemIconName: String?
	var assetIconName: String?
	var serverIconURL: String?
	var bgColor: Color?
	var noIndicator = false // Don't show capsule
	var isLoading: Bool = false
	let onSelect: () -> Void
	@State private var hovered = false

	let capsuleAnimation = Animation.interpolatingSpring(stiffness: 500, damping: 30)

	var body: some View {
		HStack {
			Capsule()
				.scale((selected || hovered) && !noIndicator ? 1 : 0)
				.fill(Color(nsColor: .labelColor))
				.frame(width: 8, height: selected ? 40 : (hovered ? 20 : 8))
				.animation(capsuleAnimation, value: selected)
				.animation(capsuleAnimation, value: hovered)

			Button(name, action: onSelect)
				.buttonStyle(
					ServerButtonStyle(
						selected: selected,
						guild: guild,
						name: name,
						bgColor: bgColor,
						systemName: systemIconName,
						assetName: assetIconName,
						serverIconURL: serverIconURL,
						loading: isLoading,
						hovered: $hovered
					)
				)
				.popover(isPresented: $hovered) {
					Text(name)
						.font(.title3)
						.padding(8)
						.frame(maxWidth: 300)
						.interactiveDismissDisabled()
				}
				.padding(.trailing, 8)
			
			Spacer()
		}
		.frame(width: 72, height: 48)
	}
}

struct ServerButtonStyle: ButtonStyle {
    let selected: Bool
	var guild: PreloadedGuild?
    let name: String
    let bgColor: Color?
    let systemName: String?
    let assetName: String?
    let serverIconURL: String?
    let loading: Bool
    @Binding var hovered: Bool
	
	@EnvironmentObject var gateway: DiscordGateway

	func makeBody(configuration: Configuration) -> some View {
		ZStack {
			if let assetName {
				Image(assetName)
					.resizable()
					.scaledToFit()
					.frame(width: 26)
			} else if let systemName {
				Image(systemName: systemName)
					.font(.system(size: 24))
			} else if let serverIconURL, let iconURL = URL(string: serverIconURL) {
				if iconURL.isAnimatable {
					SwiftyGifView(
						url: iconURL.modifyingPathExtension("gif"),
						animating: hovered,
						resetWhenNotAnimating: true
					).transition(.customOpacity)
				} else {
					BetterImageView(url: iconURL) {
						configuration.label.font(.system(size: 18))
					}
				}
			} else {
				let iconName = name.split(separator: " ").map({ $0.prefix(1) }).joined(separator: "")
				Text(iconName)
					.font(.system(size: 18))
					.lineLimit(1)
					.minimumScaleFactor(0.5)
					.padding(5)
			}
		}
		.frame(width: 48, height: 48)
		.foregroundColor(hovered || selected ? .white : Color(nsColor: .labelColor))
		.background(
			hovered || selected
			? (serverIconURL != nil ? .gray.opacity(0.35) : bgColor ?? Color.accentColor)
			: .gray.opacity(0.25)
		)
		/*.background(LinearGradient(
		 gradient: hovered || selected
		 ? (bgColor != nil ? Gradient(colors: [bgColor!])
		 : Gradient(stops: [
		 .init(color: .blue, location: 0),
		 .init(color: .yellow, location: 0.5)
		 ]))
		 : Gradient(colors: [.gray.opacity(0.25)]), startPoint: .top, endPoint: .bottom))*/
		.mask {
			RoundedRectangle(cornerRadius: hovered || selected ? 16 : 24, style: .continuous)
		}
		.offset(y: configuration.isPressed ? 1 : 0)
		.animation(.none, value: configuration.isPressed)
        .animation(.interpolatingSpring(stiffness: 500, damping: 30), value: hovered)
        .onHover { hover in hovered = hover }
		.contextMenu {
			if guild != nil {
				Text(name)
				
				Divider()
				
				Button(action: { Task { await readAll() } }) {
					Image(systemName: "message.badge")
					Text("Mark as read")
				}
				
				Divider()
				
				Group {
					Button(action: copyLink) {
						Image(systemName: "link")
						Text("Copy Link")
					}
					Button(action: copyId) {
						Image(systemName: "number.circle.fill")
						Text("Copy ID")
					}
				}
			}
		}
	}
}

private extension ServerButtonStyle {
	func readAll() async {
		if let guild = guild {
			for channel in guild.channels {
				do {
					let _ = try await restAPI.ackMessageRead(id: channel.id, msgID: channel.last_message_id ?? "", manual: true, mention_count: 0)
				} catch {}
			}
		}
	}
	
	func copyLink() {
		if let guild = guild {
			let pasteboard = NSPasteboard.general
			pasteboard.clearContents()
			pasteboard.setString(
				"https://canary.discord.com/channels/\(guild.id)",
				forType: .string
			)
		}
	}
	
	func copyId() {
		if let guild = guild {
			let pasteboard = NSPasteboard.general
			pasteboard.clearContents()
			pasteboard.setString(
				guild.id,
				forType: .string
			)
		}
	}
}
