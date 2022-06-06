//
//  AppSettingsAccessibilityView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/6/22.
//

import AVFoundation
import SwiftUI

struct AppSettingsAccessibilityView: View {
	@AppStorage("stickerAlwaysAnim") private var alwaysAnimStickers = true
	@AppStorage("showSendBtn") private var showSendButton = false
	@AppStorage("ttsRate") private var ttsRate = 0.5

    var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("settings.app.accessibility").font(.title)
			
			Text("settings.app.accessibility.chatInput")
				.font(.headline)
				.textCase(.uppercase)
				.opacity(0.75)
			VStack(alignment: .leading) {
				Toggle(isOn: $alwaysAnimStickers) {
					Text("Always animate stickers").frame(maxWidth: .infinity, alignment: .leading)
				}
				.toggleStyle(.switch)
				.tint(.green)
				if !alwaysAnimStickers {
					Text("settings.animInteraction").font(.caption)
				}
			}

			Divider()

			Text("settings.app.accessibility.chatInput")
				.font(.headline)
				.textCase(.uppercase)
				.opacity(0.75)
			Toggle(isOn: $showSendButton) {
				Text("settings.showSendBtn").frame(maxWidth: .infinity, alignment: .leading)
			}
			.toggleStyle(.switch)
			.tint(.green)

			Divider()

			Text("settings.tts.rate").font(.headline).textCase(.uppercase).opacity(0.75)
			Button {
				let text = "This is what text-to-speech sounds like at the current speed"

				let utterance = AVSpeechUtterance(string: text)
				utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
				if ttsRate != 0.5 { utterance.rate = Float(ttsRate) }

				let synthesizer = AVSpeechSynthesizer()
				synthesizer.speak(utterance)
			} label: {
				Label("Preview", systemImage: "play.fill")
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.large)
			VStack(alignment: .leading, spacing: 0) {
				HStack {
					Text("Slower").font(.subheadline).opacity(0.75)
					Spacer()
					Text("settings.tts.defaultSpeed").font(.subheadline).foregroundColor(.green)
					Spacer()
					Text("Faster").font(.subheadline).opacity(0.75)
				}
				Slider(value: $ttsRate, in: 0...1, step: 0.1)
				Text(String(format: "%.1f", ttsRate))
					.font(.subheadline)
					.frame(maxWidth: .infinity, alignment: .trailing)
			}
		}
    }
}
