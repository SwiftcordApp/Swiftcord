//
//  EmbedView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/2/22.
//

import SwiftUI
import CachedAsyncImage
import DiscordAPI

struct EmbedView: View {
    let embed: Embed
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                if let title = embed.title {
                    Text(title)
                        .font(.title3)
                        .textSelection(.enabled)
                }
                if let description = embed.description {
                    Text(description)
                        .textSelection(.enabled)
                        .opacity(0.9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if let fields = embed.fields {
                    ForEach(fields) { field in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(field.name)
                                    .font(.headline)
                                    .textSelection(.enabled)
                            Text(field.value).opacity(0.9)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                
                if let image = embed.image {
                    let width = Double(image.width != nil ? min(384, image.width!) : 384)
                    let height = (image.width != nil && image.height != nil)
                        ? width / (Double(image.width!) / Double(image.height!))
                        : 216
                    CachedAsyncImage(url: URL(string: image.url)!) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else if phase.error != nil {
                            
                        } else {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(width: width, height: height)
                        }
                    }
                    .frame(
                        width: width,
                        height: height
                    )
                    .cornerRadius(4)
                }
            }.padding(8)
        }
        .overlay(
            HStack {
                // Man, what a hack
                ZStack {
                    Capsule()
						.fill(embed.color != nil ? Color(hex: embed.color!) : Color.accentColor)
                        .frame(minWidth: 8, maxWidth: 8, maxHeight: .infinity)
                        .offset(x: 2)
                }
                .frame(maxWidth: 4, maxHeight: .infinity)
                .clipped()
                Spacer()
            }
        )
        .frame(minWidth: 400, maxWidth: 520, alignment: .leading)
    }
}

struct EmbedView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
