//
//  ServerFolder.swift
//  Swiftcord
//
//  Created by Teddy Gaillard on 9/5/22.
//

import SwiftUI
import DiscordKitCore
import DiscordKitCommon

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
                        open.toggle()
                        if open {
                            UserDefaults.standard.setValue(true, forKey: "folders.\(folder.id).open")
                        } else {
                            UserDefaults.standard.removeObject(forKey: "folders.\(folder.id).open")
                        }
                    }.onAppear {
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
                        ForEach(folder.guilds) { [self] guild in
                            ServerButton(
                                selected: selectedGuildID == guild.id || loadingGuildID == guild.id,
                                name: guild.name,
                                serverIconURL: guild.icon != nil ? "\(GatewayConfig.default.cdnURL)icons/\(guild.id)/\(guild.icon!).webp?size=240" : nil,
                                isLoading: loadingGuildID == guild.id,
                                onSelect: { selectedGuildID = guild.id }
                            )
                            // Prevent server buttons from "fading in" during transition
                            .transition(.identity)
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
        let guilds: [Guild]
        let color: Color

        var id: Snowflake {
            self.guilds.first?.id ?? ""
        }
    }
}

struct ServerFolderButtonStyle: ButtonStyle {
    let open: Bool
    let color: Color
    let guilds: [Guild]
    var filledGuilds: [Guild?] {
        guilds + [Guild?](repeating: nil, count: 4 - guilds.count)
    }
    @Binding var hovered: Bool

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if open {
                Image(systemName: "folder.fill")
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom)))
            } else {
                LazyVGrid(columns: [
                    GridItem(.fixed(16), spacing: 4),
                    GridItem(.fixed(16), spacing: 4)
                ], spacing: 4) {
                    ForEach(filledGuilds, id: \.?.id) { guild in
                        if let guild = guild {
                            MiniServerThumb(guild: guild, animate: hovered)
                        } else {
                            Circle().fill(.clear)
                        }
                    }
                }
                .foregroundColor(hovered ? .white : Color(nsColor: .labelColor))
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
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
        .animation(.linear(duration: 0.1), value: open)
    }
}

struct MiniServerThumb: View {
    let guild: Guild
    let animate: Bool

    var body: some View {
        if let serverIconPath = guild.icon, let iconURL = URL(string: "\(GatewayConfig.default.cdnURL)icons/\(guild.id)/\(serverIconPath).webp?size=240") {
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
                BetterImageView(url: iconURL, imageModifier: { $0.antialiased(true) })
                    .frame(width: 16, height: 16)
                    .cornerRadius(8)
            }
        } else {
            let iconName = guild.name.split(separator: " ").map({ $0.prefix(1) }).joined(separator: "")
            Text(iconName)
                .font(.system(size: iconName.count < 7 ? CGFloat((6 - iconName.count)*2) : 10))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 16, height: 16)
                .background(.gray.opacity(0.15))
                .cornerRadius(8)
        }
    }
}
