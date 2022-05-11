//
//  MediaControllerView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 10/5/22.
//

import SwiftUI

struct MediaControllerView: View {
    @State var progress = 0.0
    @State private var isSeeking = false
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Media Center").font(.title2).fontWeight(.semibold)
            Slider(
                value: $progress,
                in: 0...100
            ) {
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            } onEditingChanged: { editing in
                isSeeking = editing
            }
        }
        .frame(width: 400)
        .padding()
    }
}
