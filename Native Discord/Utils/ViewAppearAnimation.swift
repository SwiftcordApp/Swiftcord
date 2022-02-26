//
//  ViewAppearAnimation.swift
//  Native Discord
//
//  Created by Vincent Kwok on 26/2/22.
//

import SwiftUI

extension View {
    func animate(using animation: Animation = .easeInOut(duration: 1), _ action: @escaping () -> Void) -> some View {
        onAppear {
            withAnimation(animation) {
                action()
            }
        }
    }
}
