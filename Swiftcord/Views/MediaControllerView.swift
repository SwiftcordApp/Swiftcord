//
//  MediaControllerView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 10/5/22.
//

import SwiftUI

struct MediaControllerView: View {
    @EnvironmentObject var audioManager: AudioCenterManager

    @State private var isSeeking = false
    @State private var progress = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Media Center").font(.title2).fontWeight(.semibold)

            Divider().padding(.vertical, 8)

            Text(audioManager.isStopped ? "Nothing's Playing" : audioManager.queue[0].filename.replacingOccurrences(of: "_", with: " "))
                .font(.headline)
            Text(
                audioManager.isStopped
                ? "Select an audio file in a channel to play it!"
                : audioManager.queue[0].from
            )
            .font(.subheadline)
            .opacity(0.77)

            Slider(value: $progress, in: 0...audioManager.duration) {
            } onEditingChanged: { editing in
                isSeeking = editing
                if !editing { audioManager.seekTo(seconds: progress) }
            }.padding(.top, 4).disabled(audioManager.isStopped)
            HStack {
                Text(progress.humanReadableTime())
                Spacer()
                Text(audioManager.duration.humanReadableTime())
            }

            HStack(spacing: 20) {
                Button { audioManager.cycleLoopMode() } label: {
                    Image(systemName: audioManager.loopMode == .single ? "repeat.1" : "repeat")
                        .font(.system(size: 18)).opacity(0.8)
                        .foregroundColor(audioManager.loopMode == .disabled ? .white: .accentColor)
                }.buttonStyle(.plain).disabled(audioManager.isStopped)

                Button {
                    if audioManager.isPlaying { audioManager.pause() } else { audioManager.resume() }
                } label: {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 32))
                }.buttonStyle(.plain).disabled(audioManager.isStopped).frame(width: 34, height: 34)

                Button {
                    audioManager.remove(at: 0)
                    audioManager.playQueued(index: 0)
                } label: {
                    Image(systemName: "forward.end.fill").font(.system(size: 18)).opacity(0.8)
                }
                .buttonStyle(.plain)
                .disabled(audioManager.isStopped || audioManager.queue.count == 1)
            }.frame(maxWidth: .infinity)

            Divider().padding(.vertical, 8)

            Text("Up Next").font(.title3).fontWeight(.semibold)
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(Array(audioManager.queue.enumerated()), id: \.element) { idx, item in
                        Button {
                            withAnimation { audioManager.playQueued(index: idx) }
                        } label: {
                            Text(item.filename.replacingOccurrences(of: "_", with: " "))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(idx == 0 ? .accentColor : .gray.opacity(0.5))
                        .padding(.top, idx == 0 ? 8 : 0)
                        .padding(.bottom, idx == audioManager.queue.count - 1 ? 12 : 0)
                    }
                    if audioManager.queue.isEmpty {
                        Text("Nothing in queue")
                            .opacity(0.77)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 12)
                    }
                }
            }
            .padding(.bottom, -12)
            .frame(maxHeight: 180)
        }
        .onAppear { progress = audioManager.progress }
        .onChange(of: audioManager.progress) { prog in
            guard !isSeeking else { return }
            progress = prog
        }
        .frame(width: 300)
        .padding(12)
    }
}
