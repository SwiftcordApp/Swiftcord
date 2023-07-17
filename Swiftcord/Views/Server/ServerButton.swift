//
//  ServerButton.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 22/2/22.
//

import SwiftUI
import CachedAsyncImage
import DiscordKit
import DiscordKitCore

struct ServerButton: View {
	@Binding var selectedID: Snowflake?
	@Binding var guildID: Snowflake?
	@Binding var name: String
	@Binding var serverIconURL: String?
	@Binding var systemIconName: String?
	@Binding var assetIconName: String?
	
	@EnvironmentObject var state: UIState
	@EnvironmentObject var gateway: DiscordGateway
	
	@State var isLoading: Bool = false
	@State var bgColor: Color?
	@State var noIndicator = false // Don't show capsule

	@State private var hovered = false

	let capsuleAnimation = Animation.interpolatingSpring(stiffness: 500, damping: 30)

	var body: some View {
		HStack {
			Capsule()
				.scale(((selectedID == guildID) || hovered) && !noIndicator ? 1 : 0)
				.fill(Color(nsColor: .labelColor))
				.frame(width: 8, height: (selectedID == guildID) ? 40 : (hovered ? 20 : 8))
				.animation(capsuleAnimation, value: selectedID == guildID)
				.animation(capsuleAnimation, value: hovered)

			Button
			{
				guard let buttonID = guildID else { return }
				
				selectedID = buttonID
				state.selectedGuildID = buttonID
			} label:
			{
				VStack {
					if let assetName = assetIconName {
						Image(assetName)
							.resizable()
							.scaledToFit()
							.frame(width: 26)
					} else if let systemName = systemIconName {
						Image(systemName: systemName)
							.font(.system(size: 24))
					} else if let serverIconURL = serverIconURL, let iconURL = URL(string: serverIconURL) {
						if iconURL.isAnimatable {
							SwiftyGifView(
								url: iconURL.modifyingPathExtension("gif"),
								animating: hovered,
								resetWhenNotAnimating: true
							).transition(.customOpacity)
						} else {
							BetterImageView(url: iconURL) {
								self.font(.system(size: 18))
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
				.roundedButtonStyle(isSelected: (selectedID == guildID), hovered: hovered, bgColor: bgColor, hasIcon: (serverIconURL != nil))
				{
					viewModifiers in viewModifiers
				}
				.onHover { hover in hovered = hover }
			}
			//.buttonStyle(PlainButtonStyle()) // <- cause for breakage
			.padding(.trailing, 8)
		}
	}
}

extension SwiftUI.View
{
	@ViewBuilder func roundedButtonStyle(isSelected: Bool, hovered: Bool, bgColor: Color?, hasIcon: Bool, transform: (Self) -> some SwiftUI.View) -> some SwiftUI.View
	{
		transform(self)
			.frame(width: 48, height: 48)
			.background(hovered || isSelected
									? (hasIcon ? .gray.opacity(0.35) : bgColor ?? Color.accentColor)
									: .gray.opacity(0.25)
			)
			.mask(RoundedRectangle(cornerRadius: hovered || isSelected ? 16 : 24, style: .continuous))
			.offset(y: isSelected ? 1 : 0)
			.animation(.none, value: isSelected)
			.animation(.interpolatingSpring(stiffness: 500, damping: 30), value: hovered)
			.foregroundColor(hovered || isSelected ? .white : Color(nsColor: .labelColor))
			.contentShape(RoundedRectangle(cornerRadius: hovered || isSelected ? 16 : 24, style: .continuous))
			.cornerRadius(hovered || isSelected ? 16 : 24)
	}
}

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

struct ServerButton_Previews: PreviewProvider {
    static var previews: some View {
        ServerButton(
						selectedID: .constant(nil),
						guildID: .constant(nil),
						name: .constant("Hello world, discord!"),
						serverIconURL: .constant(nil),
						systemIconName: .constant(nil),
						assetIconName: .constant(nil),
            bgColor: nil
				)
    }
}
