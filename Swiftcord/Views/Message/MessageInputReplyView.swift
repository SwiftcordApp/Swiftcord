//
//  MessageInputReplyView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 11/8/22.
//

import SwiftUI
import DiscordKitCommon

struct MessageInputReplyView: View {
	@Binding var replying: MessagesView.ViewModel.ReplyRef?

    var body: some View {
		if let replyingRef = replying {
			HStack(spacing: 12) {
				Text("Replying to **\(replyingRef.authorUsername)**")
				Spacer()
				Divider()
				Button {
					withAnimation {
						replying = nil
					}
				} label: {
					Image(systemName: "x.circle.fill").font(.system(size: 16))
				}.buttonStyle(.plain)
			}
			.fixedSize(horizontal: false, vertical: true)
			.padding(.horizontal, 16)
			.padding(.vertical, 8)
			.background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
		}
    }
}
