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
		Section("settings.app.accessibility.chatInput") {
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
		}

		Section("settings.app.accessibility.chatInput") {
			Toggle(isOn: $showSendButton) {
				Text("settings.showSendBtn").frame(maxWidth: .infinity, alignment: .leading)
			}
			.toggleStyle(.switch)
			.tint(.green)
		}

		Section {
			VStack(alignment: .leading, spacing: 0) {
				Slider(value: $ttsRate, in: 0...1, step: 0.1) {
					Text("Narration speed")
				} minimumValueLabel: {
					Text("Slower").font(.subheadline).opacity(0.75)
				} maximumValueLabel: {
					Text("Faster").font(.subheadline).opacity(0.75)
				}
			}
		} header: {
			Text("settings.tts.rate")
		} footer: {
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
		}
    }
}
