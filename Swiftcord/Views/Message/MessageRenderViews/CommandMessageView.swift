//
//  CommandMessageView.swift
//  Swiftcord
//
//  Created by King Fish on 6/30/23.
//

import SwiftUI
import DiscordKitCore

/// For rendering chat commands
struct CommandMessageView: View {
	let message: Message

	@EnvironmentObject var serverCtx: ServerContext

	var body: some View {
		HStack(alignment: .top, spacing: 4) {
			RoundedRectangle(cornerRadius: 5)
				.trim(from: 0.5, to: 0.75)
				.stroke(.gray.opacity(0.4), lineWidth: 2)
				.frame(width: 60, height: 20)
				.padding(.top, 8)
				.padding(.bottom, -12)
				.padding(.trailing, -30)

			if let interaction = message.interaction {
				Group {
					UserAvatarView(
						user: interaction.user,
						guildID: serverCtx.guild?.id,
						webhookID: nil,
						size: 16
					)
					
					Group {
						Text("\(interaction.user.username) used")
							.font(.system(size: 14))
							.opacity(0.9)
						
						if message.type == .chatInputCmd {
							Text("/\(interaction.name)")
								.font(.system(size: 14))
								.foregroundColor(.accentColor)
						} else if message.type == .contextMenuCmd {
							Text(interaction.name)
								.font(.system(size: 14))
								.foregroundColor(.accentColor)
						}
					}
				}
			}
			Spacer()
		}
		.padding(.leading, 20)
	}
}
