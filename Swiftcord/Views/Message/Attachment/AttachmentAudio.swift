//
//  AttachmentAudioView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 3/8/22.
//

import SwiftUI
import DiscordKitCore

struct AttachmentAudio: View {
	let attachment: Attachment
	let url: URL

	@EnvironmentObject var audioManager: AudioCenterManager
	@EnvironmentObject var serverCtx: ServerContext

	private func queueSong() {
		audioManager.append(
			source: url,
			filename: attachment.filename,
			from: "\(serverCtx.guild!.properties.name) > #\(serverCtx.channel?.name ?? "")"
		)
	}

	var body: some View {
		GroupBox {
			HStack {
				VStack(alignment: .leading, spacing: 4) {
					Text(attachment.filename)
						.font(.system(size: 15))
						.fontWeight(.medium)
						.truncationMode(.middle)
						.lineLimit(1)
					Text("\(attachment.size.humanReadableFileSize()) • \(attachment.filename.fileExtension.uppercased())")
						.font(.caption)
						.opacity(0.5)
				}
				.frame(maxWidth: .infinity, alignment: .leading)

				Button { queueSong() } label: {
					Image(systemName: "text.append").font(.system(size: 18))
				}
				.buttonStyle(.borderless)
				.help("Append to queue")

				Button {
					queueSong()
					audioManager.playQueued(index: 0)
				} label: {
					Image(systemName: "play.fill").font(.system(size: 20)).frame(width: 36, height: 36)
				}
				.buttonStyle(.borderless)
				.background(Circle().fill(Color.accentColor))
				.help("Play now")
			}.padding(4)
		}.frame(width: 400)
	}
}
