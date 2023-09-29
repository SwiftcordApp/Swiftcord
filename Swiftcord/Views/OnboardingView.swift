//
//  OnboardingView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 15/6/22.
//

import SwiftUI

struct OnboardingWelcomeView: View {
	@Binding var presenting: Bool
	@Binding var showingNew: Bool
	let loadingNew: Bool
	let hasNew: Bool

	var attributedTitle: AttributedString {
		var attributedString: AttributedString = .init(localized: "onboarding.title \(appName ?? "")")

		let appNameRange = attributedString.range(of: appName ?? "")

		if let appNameRange = appNameRange {
			attributedString[appNameRange].foregroundColor = .accentColor
			attributedString[appNameRange].font = .system(size: 72).weight(.heavy)
		}

		return attributedString
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Group {
				Text(attributedTitle)
					.font(.largeTitle)

				Text("onboarding.subtitle").padding(.top, -20)
			}
			.padding(.top, 6)
			.padding(.horizontal, 8)
			.fixedSize(horizontal: false, vertical: true)

			Divider()

			HStack(spacing: 16) {
				Image(systemName: "cpu").foregroundColor(.green).font(.system(size: 32)).frame(width: 32)
				VStack(alignment: .leading, spacing: 4) {
					Text("onboarding.lightweight.header").font(.title3)
					Text("onboarding.lightweight.body")
						.opacity(0.75)
						.fixedSize(horizontal: false, vertical: true)
				}
			}.padding(.leading, 4)
			HStack(spacing: 16) {
				Image(systemName: "checkmark.circle").foregroundColor(.orange).font(.system(size: 32)).frame(width: 32)
				VStack(alignment: .leading, spacing: 4) {
					Text("onboarding.features.header").font(.title3)
					Text("onboarding.features.body")
						.opacity(0.75)
						.fixedSize(horizontal: false, vertical: true)
				}
			}.padding(.leading, 4)
			HStack(spacing: 16) {
				Image(systemName: "hammer").foregroundColor(.blue).font(.system(size: 32)).frame(width: 32)
				VStack(alignment: .leading, spacing: 4) {
					Text("onboarding.wip.header").font(.title3)
					Text("onboarding.wip.body")
						.opacity(0.75)
						.fixedSize(horizontal: false, vertical: true)
				}
			}.padding(.leading, 4)

			Spacer()

			Text("onboarding.footer").font(.caption)

			Button {
				if hasNew {
					withAnimation {
						showingNew = true
					}
				} else {
					presenting = false
				}
			} label: {
				if loadingNew {
					ProgressView()
						.controlSize(.small)
						.frame(maxWidth: .infinity)
				} else {
					Text(hasNew ? "action.continue" : "Done")
						.frame(maxWidth: .infinity)
				}
			}
			.buttonStyle(FlatButtonStyle())
			.controlSize(.large)
			.disabled(loadingNew)
		}
		.padding(16)
		.frame(width: 450, height: 550)
	}
}

struct OnboardingView: View {
	let skipOnboarding: Bool
	@Binding var skipWhatsNew: Bool
	@Binding var newMarkdown: String?

	@State private var showingNew = false
	@Binding var presenting: Bool

    var body: some View {
		if let newMarkdown = newMarkdown, showingNew || skipOnboarding {
			VStack(alignment: .leading, spacing: 0) {
				Text("What's New").font(.title)
				Divider().padding(.top, 16)
				ScrollView {
					Spacer(minLength: 16)
					Text(markdown: newMarkdown, syntax: .inlineOnly)
					Spacer(minLength: 16)
				}
				Divider().padding(.bottom, 16)
				Button {
					presenting = false
				} label: {
					Text("Done").frame(maxWidth: .infinity)
				}
				.controlSize(.large)
				.buttonStyle(FlatButtonStyle())
			}
			.padding(16)
			.frame(width: 450, height: 550)
			.transition(.backslide)
		} else {
			OnboardingWelcomeView(
				presenting: $presenting,
				showingNew: $showingNew,
				loadingNew: newMarkdown == nil && !skipWhatsNew,
				hasNew: newMarkdown != nil
			)
			.transition(.backslide)
		}
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
		// OnboardingView(presenting: .constant(true))
		EmptyView()
    }
}
