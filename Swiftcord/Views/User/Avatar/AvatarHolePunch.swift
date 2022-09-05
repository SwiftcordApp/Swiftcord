//
//  AvatarHolePunch.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/9/22.
//

import SwiftUI

struct AvatarHolePunch: View {
	let size: CGFloat
	let punchOffset: CGFloat
	let punchSize: CGFloat

	var body: some View {
		ZStack(alignment: .topLeading) {
			Circle().fill(.white).frame(width: size, height: size)
			Circle()
				.fill(.black)
				.frame(width: punchSize, height: punchSize)
				.offset(x: punchOffset, y: punchOffset)
		}
		.background(.black)
		.compositingGroup()
		.luminanceToAlpha()
		/*.compositingGroup()
		.luminanceToAlpha()*/
	}
}
