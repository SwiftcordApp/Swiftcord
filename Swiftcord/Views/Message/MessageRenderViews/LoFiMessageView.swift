//
//  LoFiMessage.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 10/5/22.
//

import SwiftUI

struct LoFiMessageView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle().fill(.gray.opacity(0.12)).frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 3) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(Double.random(in: 0.2...0.35)))
                    .frame(width: Double.random(in: 80...120), height: 16)
                TagCloudView(content: (0..<Int.random(in: 3...24))
                    .map { _ in Double.random(in: 30...80) }
                    .map { width in
						RoundedRectangle(cornerRadius: 8)
							.fill(.gray.opacity(0.12))
							.frame(width: width, height: 16)
							.padding(.bottom, 1)
                    }
                ).padding(.horizontal, -2)

                if Double.random(in: 0...1) < 0.3 {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.gray.opacity(0.05))
                        .frame(width: Double.random(in: 150...400), height: Double.random(in: 100...300))
                }
            }
        }
        .padding(.trailing, 32)
    }
}

struct LoFiMessageView_Previews: PreviewProvider {
    static var previews: some View {
        LoFiMessageView()
    }
}
