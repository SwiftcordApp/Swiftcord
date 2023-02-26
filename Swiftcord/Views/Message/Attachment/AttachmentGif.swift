//
//  AttachmentGif.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 3/8/22.
//

import SwiftUI

struct AttachmentGif: View {
	let width: Double
	let height: Double
	let url: URL

	var body: some View {
		SwiftyGifView(url: url)
			.frame(width: width, height: height)
			.cornerRadius(8)
	}
}

struct AttachmentGif_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentGif(
			width: 498,
			height: 280,
			url: URL(string: "https://cdn.discordapp.com/attachments/946325029094821938/1002795698670022686/doubt-press-x.gif")!
		)
    }
}
