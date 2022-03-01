//
//  EmbedView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/2/22.
//

import SwiftUI
import CachedAsyncImage

struct EmbedView: View {
    let embed: Embed
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                if embed.title != nil {
                    Text(embed.title!)
                        .font(.title3)
                        .textSelection(.enabled)
                }
                if embed.description != nil {
                    Text(.init(embed.description!))
                        .textSelection(.enabled)
                        .opacity(0.9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if embed.fields != nil {
                    ForEach(embed.fields!, id: \.id) { field in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(.init(field.name))
                                    .font(.headline)
                                    .textSelection(.enabled)
                            Text(.init(field.value)).opacity(0.9)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                
                if embed.image != nil {
                    let width = Double(embed.image!.width == nil ? min(384, embed.image!.width!) : 384)
                    let height = (embed.image!.width != nil && embed.image!.height != nil)
                        ? width / (Double(embed.image!.width!) / Double(embed.image!.height!))
                        : 216
                    CachedAsyncImage(url: URL(string: embed.image!.url)!) { phase in
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
                        .fill(embed.color != nil ? Color(hex: embed.color!) : Color("DiscordTheme"))
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
