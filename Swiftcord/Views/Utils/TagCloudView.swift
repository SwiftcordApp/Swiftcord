//
//  WrappingHStack.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 25/2/22.
//

import SwiftUI

// Adapted from: https://stackoverflow.com/a/62103264
struct TagCloudView<C: View>: View {
    let content: [C]

    @State private var totalHeight = CGFloat.zero      // << variant for ScrollView/List
								// = CGFloat.infinity  // << variant for VStack

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
        // .frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in geomatry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(0..<content.count, id: \.self) { contentIdx in
                content[contentIdx]
                    .padding(2)
                    .alignmentGuide(.leading) { dimen in
                        if abs(width - dimen.width) > geomatry.size.width {
                            width = 0
                            height -= dimen.height
                        }
                        let result = width
                        if contentIdx == content.count - 1 {
                            width = 0 // last item
                        } else {
                            width -= dimen.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if contentIdx == content.count - 1 {
                            height = 0 // last item
                        }
                        return result
                    }
            }
		}
		.heightReader($totalHeight)
    }

    private func item(for text: String) -> some View {
        Text(text)
            .padding(.all, 5)
            .font(.body)
            .background(Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(5)
    }
}
