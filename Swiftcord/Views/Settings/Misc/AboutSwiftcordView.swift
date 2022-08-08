//
//  AboutSwiftcordView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 17/5/22.
//

import SwiftUI

struct AboutSwiftcordView: View {
    var body: some View {
		ScrollView {
			VStack(spacing: 16) {
				VStack(spacing: 8) {
					Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 128, height: 128)
					Text(appName ?? "").font(.largeTitle)
					Text("Native Discord client built 100% in SwiftUI")

					// IMO its better to just crash if these are missing in the info dict.
					// If they are nil there are bigger problems than the app crashing.
					// swiftlint:disable force_cast
					Text("\(appName ?? "") version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) (Build: \(Bundle.main.infoDictionary!["CFBundleVersion"] as! String))").font(.caption)
				}.padding(.top, -20)

				Divider()

				Group {
					Text("""
						Swiftcord is open-source software and built with <3. You can find its \
						source code at [GitHub](https://github.com/SwiftcordApp/Swiftcord). Contributions and issue reports \
						are welcome too! Please also give Swiftcord a star, it gives me motivation \
						to continue working on it :D
						""")
					.multilineTextAlignment(.center)
					Text("Swiftcord is powered by [DiscordKit](https://github.com/SwiftcordApp/DiscordKit), a WIP Discord API implementation in Swift")
				}
			}.padding(40)
		}
    }
}

struct AboutSwiftcordView_Previews: PreviewProvider {
    static var previews: some View {
        AboutSwiftcordView()
    }
}
