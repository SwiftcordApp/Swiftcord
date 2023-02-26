//
//  AttachmentImage.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 3/8/22.
//

import SwiftUI
import CachedAsyncImage

struct AttachmentImage: View {
	let width: Double
	let height: Double
	let scale: Double
	let url: URL

	var body: some View {
		CachedAsyncImage(url: url, scale: scale) { phase in
			if let image = phase.image {
				image
					.resizable()
					.scaledToFill()
					.transition(.customOpacity)
			} else if phase.error != nil {
				AttachmentError(width: width, height: height).transition(.customOpacity)
			} else {
				AttachmentLoading(width: width, height: height).transition(.customOpacity)
			}
		}
		.cornerRadius(8)
		.frame(idealWidth: CGFloat(width), idealHeight: CGFloat(height))
		.fixedSize()
	}
}

struct AttachmentImageView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentImage(
			width: 800, height: 468, scale: 2, url: URL(string: "https://cdn.discordapp.com/attachments/946325029094821938/975679768576028702/heroScreenshot.png")!
		)
    }
}
