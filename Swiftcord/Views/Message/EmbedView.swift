//
//  EmbedView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 28/2/22.
//

import SwiftUI

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
                            Text(field.name)
                                    .font(.headline)
                                    .textSelection(.enabled)
                            Text(.init(field.value)).opacity(0.9)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
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
        .frame(maxWidth: 400, alignment: .leading)
    }
}

struct EmbedView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
