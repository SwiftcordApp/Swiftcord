//
//  AttachmentProgress.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 3/8/22.
//

import SwiftUI

struct AttachmentError: View {
	let width: Double
	let height: Double

	var body: some View {
		Image(systemName: "exclamationmark.square")
			.font(.system(size: min(width, height) - 10))
			.frame(width: width, height: height, alignment: .center)
	}
}

struct AttachmentLoading: View {
	let width: Double
	let height: Double

	var body: some View {
		Rectangle()
			.fill(.gray.opacity(Double.random(in: 0.15...0.3)))
			.frame(width: width, height: height, alignment: .center)
	}
}

struct AttachmentProgressView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentError(width: 400, height: 300)
		AttachmentLoading(width: 400, height: 300)
    }
}
