//
//  MessageInfoBarView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 10/5/22.
//

import SwiftUI

struct InfoBarData {
    let message: String
    let buttonLabel: String
    let color: Color
    var buttonIcon: String? = nil
    let clickHandler: () -> Void
}

struct MessageInfoBarView: View {
    @Binding var isShown: Bool
    @Binding var state: InfoBarData?
    
    var body: some View {
        HStack {
            Text(state?.message ?? "''").fontWeight(.medium)
            Spacer()
            Button { state!.clickHandler() } label: {
                if let i = state?.buttonIcon { Label(state!.buttonLabel, systemImage: i) }
                else { Text(state?.buttonLabel ?? "") }
            }.buttonStyle(.plain)
        }
        .frame(height: 24)
        .padding(.horizontal) // Padding for content
        .padding(.bottom, 14)
        .background(.red)
        .cornerRadius(8) // Visually match corner radius to message field
        .padding(.horizontal, 16) // Padding outside the background
        .offset(y: isShown ? -40 : -16)
        .animation(
            .interpolatingSpring(mass: 1.2,
                                 stiffness: 500,
                                 damping: 30,
                                 initialVelocity: isShown ? 0.03 : 0),
            value: isShown
        )
    }
}
