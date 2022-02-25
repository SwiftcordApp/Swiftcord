//
//  MessageInputView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 24/2/22.
//

import SwiftUI

struct MessageInputView: View {
    let placeholder: String
    @Binding var message: String
    
    var body: some View {
        /*GeometryReader { geometry in
            EmptyView().onAppear {
                print(geometry)
            }
        }.frame(minHeight: 40)*/

        HStack(alignment: .center, spacing: 14) {
            Button(action: {}) { Image(systemName: "plus").font(.system(size: 20)) }
                .buttonStyle(.plain)
                .padding(.leading, 15)
        
            TextEditor(text: $message)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .lineSpacing(4)
                .font(.system(size: 16))
                .lineLimit(4)
                .padding([.top, .bottom], 12)
                .overlay(alignment: .leading) {
                    if message.isEmpty {
                        Text(placeholder)
                            .padding([.leading, .trailing], 4)
                            .opacity(0.5)
                            .font(.system(size: 16, weight: .light))
                            .allowsHitTesting(false)
                    }
                }
            

            Button(action: {}) { Image(systemName: "arrow.up").font(.system(size: 20)) }
                .buttonStyle(.plain)
                .padding(.trailing, 15)
        }
        .frame(minHeight: 40)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 7)
                    .fill(Color(NSColor.textBackgroundColor)))
                .shadow(color: .gray.opacity(0.2), radius: 3)
        )
        .padding([.leading, .trailing], 16)
        .offset(y: -16)
    }
}

struct MessageInputView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
