//
//  LottieView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//  Adapted from 

import SwiftUI
import Lottie

/// SwiftUI wrapper around `Lottie.AnimationView`
public struct LottieView: NSViewRepresentable {
    public typealias NSViewType = WrapperAnimationView

    /// The animation
	let animation: Lottie.LottieAnimation?
    let width: Double
    let height: Double

    /// Flag if the animation should be played
    @Binding var play: Bool

    /// Loop mode of the animation provided by the `@Environment`
    ///
    /// You can set this property using `lottieLoopMode` method on `View`
    @Environment(\.lottieLoopMode) var loopMode: LottieLoopMode

	public init(animation: Lottie.LottieAnimation, play: Binding<Bool>, width: Double, height: Double) {
        self.animation = animation
        self._play = play
        self.width = width
        self.height = height
    }

    public init(name: String, play: Binding<Bool>, width: Double, height: Double) {
        animation = .named(name)
        self._play = play
        self.width = width
        self.height = height
    }

    public init(filepath: String, play: Binding<Bool>, width: Double, height: Double) {
        animation = .filepath(filepath)
        _play = play
        self.width = width
        self.height = height
    }

    // MARK: - UIViewRepresentable
    public func makeNSView(context: Context) -> WrapperAnimationView {
        WrapperAnimationView(animation: animation, width: width, height: height)
    }

    public func updateNSView(_ uiView: WrapperAnimationView, context: Context) {
        // print("Updated: \(play)")
        uiView.loopMode = loopMode
        if play {
            uiView.play { completed in if completed { self.play = false } }
        } else {
            uiView.stop()
            // play = false
        }
    }
}

extension LottieView {
    /// Convenient initializer which sets `play` to `.constant(true)`.
    public init(name: String) {
        self.init(name: name, play: .constant(true), width: 160, height: 160)
    }
}
