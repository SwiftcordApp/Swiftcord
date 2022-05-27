//
//  ServerButton.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 22/2/22.
//

import SwiftUI
import CachedAsyncImage

struct ServerButton: View {
	let selected: Bool
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

			Button(action: onSelect) {
				Text(systemIconName == nil && assetIconName == nil
					 ? name.split(separator: " ").map({ $0.prefix(1) }).joined(separator: "")
					 : ""
				)
			}
			.buttonStyle(
				ServerButtonStyle(
					selected: selected,
					name: name,
					bgColor: bgColor,
					systemName: systemIconName,
					assetName: assetIconName,
					serverIconURL: serverIconURL,
					loading: isLoading,
					hovered: $hovered
				)
			)
			/*.popover(isPresented: .constant(true)) {
			 Text(name).padding(8)
			 }*/
			.padding(.trailing, 8)

			Spacer()
		}
		.frame(width: 72, height: 48)
	}
}

struct ServerButtonStyle: ButtonStyle {
    let selected: Bool
    let name: String
    let bgColor: Color?
    let systemName: String?
    let assetName: String?
    let serverIconURL: String?
    let loading: Bool
    @Binding var hovered: Bool

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if let assetName = assetName {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26)
            } else if let systemName = systemName {
                Image(systemName: systemName)
                    .font(.system(size: 24))
            } else if let serverIconURL = serverIconURL {
                CachedAsyncImage(url: URL(string: serverIconURL)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else if phase.error != nil {
                        configuration.label.font(.system(size: 18))
                    } else {
                        ProgressView().progressViewStyle(.circular)
                    }
                }
            } else {
				configuration.label
					.font(.system(size: 15))
					.lineLimit(1)
			}
        }
        .frame(width: 48, height: 48)
		.foregroundColor(hovered || selected ? .white : Color(nsColor: .labelColor))
        .background(
            hovered || selected
			? bgColor ?? Color.accentColor
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
		.offset(y: configuration.isPressed ? 2 : 0)
        .animation(.interpolatingSpring(stiffness: 500, damping: 25), value: configuration.isPressed)
        .animation(.interpolatingSpring(stiffness: 500, damping: 30), value: hovered)
        .onHover { hover in hovered = hover }
        .cursor(NSCursor.pointingHand)
    }
}

struct ServerButton_Previews: PreviewProvider {
    static var previews: some View {
        ServerButton(
            selected: false,
            name: "Hello world, discord!",
            systemIconName: nil,
            assetIconName: nil,
            serverIconURL: nil,
            bgColor: nil,
            onSelect: {}
        )
    }
}
