//
//  LottieLoopMode.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import SwiftUI
import Lottie

struct LottieLoopModeKey: EnvironmentKey {
    static var defaultValue: LottieLoopMode = .playOnce
}

extension EnvironmentValues {
    var lottieLoopMode: LottieLoopMode {
        get { self[LottieLoopModeKey.self] }
        set { self[LottieLoopModeKey.self] = newValue }
    }
}

extension View {
    public func lottieLoopMode(_ mode: LottieLoopMode) -> some View {
        environment(\.lottieLoopMode, mode)
    }
}
