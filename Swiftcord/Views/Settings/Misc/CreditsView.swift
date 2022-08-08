//
//  CreditsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 8/8/22.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Credits").font(.title)
			VStack(alignment: .center, spacing: 2) {
				Image(systemName: "person.fill").font(.system(size: 24)).foregroundColor(.yellow)
				Text("Head Developer").font(.title2).padding(.top, 8)
				Text("Vincent Kwok")
			}.frame(maxWidth: .infinity)
			HStack(alignment: .top, spacing: 16) {
				VStack(alignment: .center, spacing: 2) {
					Image(systemName: "person.3")
						.font(.system(size: 24)).foregroundColor(.green)
					Text("Contributors").font(.title2).padding(.top, 8)

					Text("Thanks to all those who made valuable contributions! Swiftcord wouldn't be where it is without your contributions!")
						.multilineTextAlignment(.center)
						.padding(.bottom, 4)

					Group {
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
						Link("selimgr",
							 destination: URL(string: "https://github.com/selimgr")!)
						Link("tonyarnold",
							 destination: URL(string: "https://github.com/tonyarnold")!)
						Link("charxene",
							 destination: URL(string: "https://github.com/charxene")!)
					}

					Text("Big thanks to all contributors <3")
						.padding(.top, 4)
						.font(.caption)
						.multilineTextAlignment(.center)
				}.frame(maxWidth: .infinity)
				VStack(alignment: .center, spacing: 2) {
					Image(systemName: "dollarsign.circle")
						.font(.system(size: 24)).foregroundColor(.orange)
					Text("Sponsors").font(.title2).padding(.top, 8)

					Text("Sponsoring Swiftcord allows me to continue developing it!")
						.multilineTextAlignment(.center)
						.padding(.bottom, 4)

					Link("selimgr",
						 destination: URL(string: "https://github.com/selimgr")!)

					Text("Please sponsor Swiftcord on GitHub! I'll be eternally grateful <3")
						.padding(.top, 4)
						.font(.caption)
				}.frame(maxWidth: .infinity)
			}
			Link(destination: URL(string: "https://www.reddit.com/r/discordapp/comments/k6s89b/i_recreated_the_discord_loading_animation/")!) {
				Text("Thanks to iJayTD on Reddit for recreating the Discord loading animation and agreeing to its use in Swiftcord!").multilineTextAlignment(.leading)
			}
			Text("And finally, thanks to Discord for building such an amazing community and infrastructure!").font(.subheadline)
		}
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
