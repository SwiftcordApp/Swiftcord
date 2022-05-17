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
			VStack(alignment: .leading, spacing: 16) {
				HStack(spacing: 16) {
					Image(nsImage: NSImage(named: "AppIcon")!).resizable().frame(width: 128, height: 128)
					VStack(alignment: .leading, spacing: 8) {
						Text("Swiftcord").font(.largeTitle)
						Text("A completely native Discord client for macOS built 100% in Swift and SwiftUI. Light on your CPU and RAM.")
						Text("Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) (Build: \(Bundle.main.infoDictionary!["CFBundleVersion"] as! String))").font(.caption)
					}
					Spacer()
				}.padding([.horizontal, .top], -20)
				
				Divider()
				
				Text("Credits").font(.title)
				VStack(alignment: .center, spacing: 2) {
					Image(systemName: "person.fill").font(.system(size: 24))
					Text("Head Developer").font(.title2).padding(.top, 8)
					Text("Vincent Kwok")
				}.frame(maxWidth: .infinity)
				HStack(alignment: .top, spacing: 16) {
					VStack(alignment: .center, spacing: 2) {
						Image(systemName: "person.3").font(.system(size: 24))
						Text("Contributors").font(.title2).padding(.top, 8)
						Link("Anthony Ingle",
							 destination: URL(string: "https://github.com/ingleanthony")!)
						Link("Ben Tettmar",
							 destination: URL(string: "https://github.com/bentettmar")!)
						Link("royal",
							 destination: URL(string: "https://github.com/rrroyal")!)
						Link("Candygoblen123",
							 destination: URL(string: "https://github.com/Candygoblen123")!)
						Link("marcprux",
							 destination: URL(string: "https://github.com/marcprux")!)
						
						Text("Big thanks to all contributors <3! Contributions are more than welcome :D")
							.padding(.top, 4)
							.font(.caption)
							.multilineTextAlignment(.center)
					}.frame(maxWidth: .infinity)
					VStack(alignment: .center, spacing: 2) {
						Image(systemName: "dollarsign.circle").font(.system(size: 24))
						Text("Sponsors").font(.title2).padding(.top, 8)
						Text("Nobody yet...")
						
						Text("Please sponsor the project on GitHub!")
							.padding(.top, 4)
							.font(.caption)
					}.frame(maxWidth: .infinity)
				}
				Link(destination: URL(string: "https://www.reddit.com/r/discordapp/comments/k6s89b/i_recreated_the_discord_loading_animation/")!) {
					Text("Thanks to iJayTD on Reddit for recreating the Discord loading animation and agreeing to its use in Swiftcord!").multilineTextAlignment(.leading)
				}
				Text("And finally, thanks to Discord for building such an amazing community and infrastructure!").font(.subheadline)
				
				Group {
					Divider()
					
					Text("Swiftcord is open-source software and built with love. You can find its source code in GitHub at the link below! Contributions and issue reports are welcome ;) Please also give Swiftcord a star, it gives me motivation to continue working on it.").font(.headline)
					Link("Swiftcord on GitHub",
						 destination: URL(string: "https://github.com/SwiftcordApp/Swiftcord")!)
					
					Link("Swiftcord is powered by DiscordKit, a Discord API implementation in Swift",
						 destination: URL(string: "https://github.com/SwiftcordApp/DiscordKit")!)
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
