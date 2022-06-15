//
//  OnboardingView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 15/6/22.
//

import SwiftUI

struct OnboardingView: View {
	@Binding var presenting: Bool

    var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Group {
				Text("onboarding.title").font(.largeTitle)
				+ Text(appName ?? "")
					.foregroundColor(.accentColor)
					.font(.system(size: 72))
					.fontWeight(.heavy)
				Text("onboarding.subtitle").padding(.top, -20)
			}
			.padding(.top, 6)
			.padding(.horizontal, 8)

			Divider()

			HStack(spacing: 16) {
				Image(systemName: "cpu").foregroundColor(.green).font(.system(size: 32)).frame(width: 32)
				VStack(alignment: .leading, spacing: 4) {
					Text("onboarding.lightweight.header").font(.title3)
					Text("onboarding.lightweight.body").opacity(0.75)
				}
			}.padding(.leading, 4)
			HStack(spacing: 16) {
				Image(systemName: "checkmark.circle").foregroundColor(.orange).font(.system(size: 32)).frame(width: 32)
				VStack(alignment: .leading, spacing: 4) {
					Text("onboarding.features.header").font(.title3)
					Text("onboarding.features.body").opacity(0.75)
				}
			}.padding(.leading, 4)
			HStack(spacing: 16) {
				Image(systemName: "hammer").foregroundColor(.blue).font(.system(size: 32)).frame(width: 32)
				VStack(alignment: .leading, spacing: 4) {
					Text("onboarding.wip.header").font(.title3)
					Text("onboarding.wip.body").opacity(0.75)
				}
			}.padding(.leading, 4)

			Spacer()

			Text("onboarding.footer").font(.caption)

			Button {
				presenting = false
			} label: {
				Text("action.continue")
					.frame(maxWidth: .infinity)
					.font(.title3)
					.padding(10)
					.background(Color.accentColor)
					.cornerRadius(4)
			}
			.buttonStyle(.plain)
		}
		.padding(16)
		.frame(width: 400, height: 530)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
		OnboardingView(presenting: .constant(true))
    }
}
