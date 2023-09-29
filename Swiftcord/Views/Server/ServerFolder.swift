//
//  ServerFolder.swift
//  Swiftcord
//
//  Created by Teddy Gaillard on 9/5/22.
//

import SwiftUI
import DiscordKitCore

/// A single server folder item
///
/// Used to render a server folder in the server list
struct ServerFolder: View {
    let folder: GuildFolder
    @State private var hovered = false
    @State var open = false
    @Binding var selectedGuildID: Snowflake?
    @State var loadingGuildID: Snowflake?

    // This creates an inverse mask of the folder open/close button,
    // so the background capsule isn't visible behind the button
    var backgroundCapsuleMaskView: some View {
        HStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.black)
                .frame(width: 48, height: 48, alignment: .top)
        }
            .frame(width: 48, height: open ? CGFloat(56 * folder.guilds.count + 48) : 48, alignment: .top)
        .background(.white)
        .compositingGroup()
        .luminanceToAlpha()
    }

    var folderIndicator: some View {
        HStack(alignment: .center) {
            Capsule()
                .scale(hovered && !open ? 1 : 0)
                .fill(Color(nsColor: .labelColor))
                .frame(width: 8, height: hovered ? 20 : 8)
                .animation(Self.capsuleAnimation, value: hovered && !open)
        }
        .frame(height: 48)
    }

    var body: some View {
        HStack(alignment: .top) {
            folderIndicator
            Spacer()

            ZStack {
                // Background tint behind servers in folder
                Capsule()
                    .fill(.gray.opacity(0.15))
                    .frame(width: 48)
                    .mask(backgroundCapsuleMaskView)

                VStack {
                    Button("") {
                        withAnimation(.interactiveSpring()) { open.toggle() }
                        if open {
                            UserDefaults.standard.setValue(true, forKey: "folders.\(folder.id).open")
                        } else {
                            UserDefaults.standard.removeObject(forKey: "folders.\(folder.id).open")
                        }
                    }
                    .onAppear {
                        open = UserDefaults.standard.bool(forKey: "folders.\(folder.id).open")
                    }
                    .buttonStyle(
                        // Server folder open/close toggle
                        ServerFolderButtonStyle(
                            open: open,
                            color: folder.color,
                            guilds: Array(folder.guilds.prefix(4)),
                            hovered: $hovered
                        )
                    )
                    .popover(isPresented: $hovered, attachmentAnchor: .point(.trailing), arrowEdge: .trailing) {
                        Text(folder.name)
                            .font(.title3)
                            .padding(10)
                        // Prevent popover from blocking clicks to other views
                            .interactiveDismissDisabled()
                    }

                    if open {
                        ForEach(folder.guilds, id: \.id) { [self] guild in
                            ServerButton(
                                selected: selectedGuildID == guild.id || loadingGuildID == guild.id,
                                name: guild.properties.name,
                                serverIconURL: guild.properties.icon != nil ? "\(DiscordKitConfig.default.cdnURL)icons/\(guild.id)/\(guild.properties.icon!).webp?size=240" : nil,
                                isLoading: loadingGuildID == guild.id
                            ) {
                                selectedGuildID = guild.id
                            }
                            .transition(.move(edge: .top).combined(with: .opacity)) // Prevent server buttons from "fading in" during transition
                        }
                    }
                }
                .frame(width: 48, height: open ? CGFloat(56 * folder.guilds.count + 48) : 48, alignment: .top)
            }
            .frame(width: 48)
            .padding(.trailing, 8)

            Spacer()
        }
        .frame(width: 72)
    }

    static let capsuleAnimation = Animation.interpolatingSpring(stiffness: 500, damping: 30)

    struct GuildFolder: Identifiable {
        let name: String
        let guilds: [PreloadedGuild]
        let color: Color

        var id: Snowflake {
            self.guilds.first?.id ?? ""
        }
    }
}

struct ServerFolderButtonStyle: ButtonStyle {
    let open: Bool
    let color: Color
    let guilds: [PreloadedGuild]
    @Binding var hovered: Bool

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if open {
                Image(systemName: "folder.fill")
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.fixed(16), spacing: 4),
                        GridItem(.fixed(16), spacing: 4)
                    ],
                    spacing: 4
                ) {
                    ForEach(guilds, id: \.id) { guild in
                        MiniServerThumb(guild: guild, animate: hovered)
                    }
                }
                .foregroundColor(hovered ? .white : Color(nsColor: .labelColor))
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(6)
            }
        }
        .frame(width: 48, height: 48)
        .background(
            open
            ? .gray.opacity(hovered ? 0.25 : 0.15)
            : color.opacity(hovered ? 0.5 : 0.4)
        )
        .mask {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
        }
        .clipped()
        .offset(y: configuration.isPressed ? 1 : 0)
        .animation(.none, value: configuration.isPressed)
        .animation(.interpolatingSpring(stiffness: 500, damping: 30), value: hovered)
        .onHover { hover in hovered = hover }
    }
}

struct MiniServerThumb: View {
    let guild: PreloadedGuild
    let animate: Bool

    var body: some View {
        if let serverIconPath = guild.properties.icon, let iconURL = URL(string: "\(DiscordKitConfig.default.cdnURL)icons/\(guild.id)/\(serverIconPath).webp?size=240") {
            if iconURL.isAnimatable {
                SwiftyGifView(
                    url: iconURL.modifyingPathExtension("gif"),
                    animating: animate,
                    resetWhenNotAnimating: true
                )
                    .transition(.customOpacity)
                    .frame(width: 16, height: 16)
                    .cornerRadius(8)
            } else {
                BetterImageView(url: iconURL) { image in image.antialiased(true) }
                    .frame(width: 16, height: 16)
                    .cornerRadius(8)
            }
        } else {
            let iconName = guild.properties.name.split(separator: " ").map { $0.prefix(1) }.joined(separator: "")
            Text(iconName)
                .font(.system(size: 8))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.white)
                .frame(width: 16, height: 16)
                .background(.gray.opacity(0.15))
                .cornerRadius(8)
        }
    }
}
