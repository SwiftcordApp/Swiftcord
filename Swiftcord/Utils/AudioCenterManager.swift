//
//  AudioManager.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 10/5/22.
//

import Foundation
import AVFoundation

struct AudioCenterItems: Hashable {
    let playerItem: AVPlayerItem
    let filename: String
    let from: String
    let addedAt: Int
}

class AudioCenterManager: ObservableObject {
    private let player = AVQueuePlayer()
    private var timeObserverToken: Any?
    
    @Published public var queue: [AudioCenterItems] = []
    @Published public var progress = 0.0
    @Published public var duration = 0.0
    @Published public var isSeeking = false
    @Published public var isStopped = true
    @Published public var isPlaying = false
    
    public func append(source: URL, filename: String, from: String, at: Int? = nil) {
        let playerItem = AVPlayerItem(url: source)
        player.insert(playerItem,
                      after: queue.isEmpty ? nil : queue[at ?? (queue.count - 1)].playerItem)
        queue.insert(AudioCenterItems(
            playerItem: playerItem,
            filename: filename,
            from: from,
            addedAt: Int(Date().timeIntervalSince1970)
        ), at: at ?? queue.count)
    }
    
    public func remove(at: Int) {
        player.remove(queue.remove(at: at).playerItem)
    }
    
    public func play() {
        player.volume = 1
        player.play()
        isPlaying = true
        isStopped = false
        progress = 0
        duration = 0
    }
    public func playQueued(index: Int) {
        if index != 0 { queue.swapAt(index, 0) }
        player.pause()
        player.removeAllItems()
        for item in queue { player.insert(item.playerItem, after: nil) }
        player.seek(to: CMTime.zero)
        play()
    }
    public func resume() {
        player.volume = 1
        player.play()
        isPlaying = true
    }
    public func pause() {
        player.pause()
        isPlaying = false
    }
    public func stop() {
        isStopped = true
        duration = 0
        progress = 0
        isPlaying = false
    }
    
    public func seekTo(seconds: Double) {
        isSeeking = true
        player.seek(
            to: CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        ) { [weak self] _ in
            self?.player.volume = 1
            self?.isSeeking = false
            print("seeked")
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("items empty: \(player.items().count)")
        if player.items().count <= 1 { stop() }
        isSeeking = false
        queue.remove(at: 0)
    }
    
    init() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) {
            [weak self] time in
            guard !(self?.isSeeking ?? true) else { return }
            self?.progress = time.seconds
            if self?.player.currentItem?.duration.isValid ?? false {
                self?.duration = (self?.player.currentItem?.duration.seconds ?? 0).fixNumbers()
            }
        }
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }
    
    deinit {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
}
