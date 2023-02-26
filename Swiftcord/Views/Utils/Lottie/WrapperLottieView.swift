//
//  WrapperLottieView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 23/2/22.
//

import AppKit
import Lottie

// Needed to have proper size with `frame` modifier
public final class WrapperAnimationView: NSView {
	let animationView: Lottie.LottieAnimationView!
    let width: Double!
    let height: Double!

	init(animation: Lottie.LottieAnimation?, width: Double, height: Double) {
        self.width = width
        self.height = height

		let animationView = LottieAnimationView(animation: animation)
        animationView.contentMode = .scaleAspectFit
        // animationView.widthAnchor
        animationView.translatesAutoresizingMaskIntoConstraints = false
        self.animationView = animationView

        super.init(frame: .zero)

        addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationView.heightAnchor.constraint(equalToConstant: height),
            animationView.widthAnchor.constraint(equalToConstant: width)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WrapperAnimationView {
    var loopMode: LottieLoopMode {
        get { animationView.loopMode }
        set { animationView.loopMode = newValue }
    }

    func play(completion: LottieCompletionBlock?) {
        // print("Animation play")
        animationView.play(completion: completion)
    }

    func stop() {
        // print("Animation stop")
        animationView.pause()
    }
}
