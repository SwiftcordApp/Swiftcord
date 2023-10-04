//
//  HorizontalDividerView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 9/7/22.
//

import SwiftUI

struct HorizontalDividerView: View {
	@State var color: Color = Color(NSColor.separatorColor)
	
	var body: some View {
		Rectangle().fill(color).frame(height: 1)
	}
}

struct HorizontalDividerView_Previews: PreviewProvider {
    static var previews: some View {
		HorizontalDividerView().frame(width: 100)
    }
}
