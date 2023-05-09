//
//  AboutSwiftcordView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 17/5/22.
//

import SwiftUI

struct AboutSwiftcordView: View {
    var body: some View {
		Section {
			// IMO its better to just crash if these are missing in the info dict.
			// If they are nil there are bigger problems than the app crashing.
			HStack {
				Text("Version")
				Spacer()
				// swiftlint:disable force_cast
				Text(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
					.foregroundColor(.secondary)
			}
			HStack {
				Text("Build")
				Spacer()
				// swiftlint:disable force_cast
				Text(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
					.foregroundColor(.secondary)
			}
		} header: {
			VStack(spacing: 4) {
				Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 128, height: 128)
				Text(appName ?? "").font(.largeTitle).foregroundColor(.primary)
				Text("settings.others.about.desc").font(.title3)
			}
			.frame(maxWidth: .infinity)
			.padding(.top, 8)
			.padding(.bottom, 16)
		}

		Section {
			Text("settings.others.about.caption")
			Text("settings.others.about.supportPkg")
		}
	}
}

struct AboutSwiftcordView_Previews: PreviewProvider {
    static var previews: some View {
        AboutSwiftcordView()
    }
}
