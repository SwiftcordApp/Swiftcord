//
//  UserSettingsPrivacySafetyView.swift
//  Swiftcord
//
//  Created by Andrew Glaze on 7/1/22.
//

import SwiftUI

struct UserSettingsPrivacySafetyView: View {
	@AppStorage("nsfwShown") var nsfwShown = true

    var body: some View {
		Toggle(isOn: $nsfwShown) {
			Text("Show NSFW channels").frame(maxWidth: .infinity, alignment: .leading)
		}
		.toggleStyle(.switch)
		.tint(.green)
    }
}
