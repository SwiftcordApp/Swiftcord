//
//  CircularProgressView.swift
//  Swiftcord
//
//  Created by Anthony Ingle on 5/9/22.
//

import SwiftUI

struct CircularProgressView: View {
    var lineWidth: Double
    @Binding var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.secondary.opacity(0.2),
                    lineWidth: lineWidth
                )

            Circle()
                .trim(from: 0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
        }
        .animation(.easeOut, value: progress)
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(lineWidth: 5, progress: .constant(0.25))
            .frame(width: 20, height: 20)
            .padding()
    }
}
