//
//  AboutSwiftcordView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 17/5/22.
//

import SwiftUI

struct AboutSwiftcordView: View {
    var body: some View {
		VStack(spacing: 16) {
			VStack(spacing: 8) {
				Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 128, height: 128)
				Text(appName ?? "").font(.largeTitle)
				Text("settings.others.about.desc")

				// IMO its better to just crash if these are missing in the info dict.
				// If they are nil there are bigger problems than the app crashing.
				// swiftlint:disable force_cast
				Text("\(appName ?? "") \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) \(Bundle.main.infoDictionary!["CFBundleVersion"] as! String) settings.others.about.ver").font(.caption)
			}

			Divider()

			Group {
				Text("settings.others.about.caption").multilineTextAlignment(.center)
				Text("settings.others.about.supportPkg")
			}
			Spacer()
		}.padding(40)
	}
}

struct AboutSwiftcordView_Previews: PreviewProvider {
    static var previews: some View {
        AboutSwiftcordView()
    }
}
