//
//  ServerButton.swift
//  Native Discord
//
//  Created by Vincent Kwok on 22/2/22.
//

import SwiftUI

struct ServerButton: View {
    @State private var hovered = false
    
    var body: some View {
        ZStack(alignment: .center) {
            
        }
        .frame(width: 48, height: 48)
        .onHover { hover in hovered = hover }
    }
}

struct ServerButton_Previews: PreviewProvider {
    static var previews: some View {
        ServerButton()
    }
}
