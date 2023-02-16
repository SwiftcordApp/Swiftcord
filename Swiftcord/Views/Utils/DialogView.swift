//
//  DialogView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 11/7/22.
//

import SwiftUI

struct DialogView<Content, ActionRowContent>: View where Content: View, ActionRowContent: View {
	let title: LocalizedStringKey
	let description: LocalizedStringKey?
	var analyticsType: String?
	var analyticsFrom: String?

	@ViewBuilder let actionRowContent: () -> ActionRowContent
	@ViewBuilder let content: () -> Content

    var body: some View {
		VStack(spacing: 16) {
			VStack(spacing: 8) {
				Text(title)
					.font(.title)
					.frame(maxWidth: .infinity, alignment: description != nil ? .center : .leading)
					.multilineTextAlignment(description != nil ? .center : .leading)
				if let description = description {
					Text(description).multilineTextAlignment(.center)
				}
			}
			.padding([.horizontal, .top], 16)
			.padding(.bottom, 8)

			VStack(alignment: .leading, spacing: 8, content: content).padding(.horizontal, 16)

			HStack {
				actionRowContent()
			}
			.padding(16)
			.background(.black.opacity(0.1))
		}
		.frame(width: 440)
		.onAppear {
			if let analyticsType = analyticsType, let analyticsFrom = analyticsFrom {
				AnalyticsWrapper.event(type: .openModal, properties: [
					"type": analyticsType,
					"location": analyticsFrom
				])
			}
		}
    }
}

struct DialogView_Previews: PreviewProvider {
	static var previews: some View {
        DialogView(
            title: "Test Dialog",
            description: "Hello"
        ) { // swiftlint:disable:this vertical_parameter_alignment_on_call
            Button {
            } label: {
                Text("Nope")
            }.buttonStyle(.plain)
            Spacer()
            Button {
            } label: {
                Text("Haha")
            }.buttonStyle(FlatButtonStyle())
        } content: {
            Text("Look at me go!")
        }
	}
}
