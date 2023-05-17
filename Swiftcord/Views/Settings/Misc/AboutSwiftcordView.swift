//
//  AboutSwiftcordView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 17/5/22.
//

import SwiftUI

struct AboutSwiftcordView: View {
	@EnvironmentObject var updaterViewModel: UpdaterViewModel

    var body: some View {
		Section {
			// IMO its better to just crash if these are missing in the info dict.
			// If they are nil there are bigger problems than the app crashing.
			// swiftlint:disable force_cast
			HStack {
				Text("Version")
				Spacer()
				Text(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
					.foregroundColor(.secondary)
			}
			HStack {
				Text("Build")
				Spacer()
				Text(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
					.foregroundColor(.secondary)
			}
			// swiftlint:enable force_cast
		} header: {
			VStack(spacing: 4) {
				Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 128, height: 128)
				Text(appName ?? "").font(.largeTitle).foregroundColor(.primary)
				Text("settings.others.about.desc").font(.title3)
			}
			.frame(maxWidth: .infinity)
			.padding(.top, 8)
			.padding(.bottom, 16)
		} footer: {
			Button("Check for Updates…", action: updaterViewModel.checkForUpdates)
				.disabled(!updaterViewModel.canCheckForUpdates)
		}

		Section {
			Text("settings.others.about.caption")
			Text("settings.others.about.supportPkg")
		}
	}
}
