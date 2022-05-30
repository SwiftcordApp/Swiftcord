//
//  ProfileAccentMask.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 30/5/22.
//

import SwiftUI

struct ProfileAccentMask: Shape {
	let insetStart: CGFloat
	let insetWidth: CGFloat

	func path(in rect: CGRect) -> Path {
		var path = Path()
		path.move(to: CGPoint(x: 0, y: 0))

		path.addLine(to: CGPoint(x: rect.width, y: 0))
		path.addLine(to: CGPoint(x: rect.width, y: rect.height))
		path.addLine(to: CGPoint(x: insetStart + insetWidth, y: rect.height))

		path.addArc(
			center: CGPoint(x: insetStart + insetWidth/2, y: rect.height),
			radius: insetWidth/2,
			startAngle: .degrees(0),
			endAngle: .degrees(180),
			clockwise: true
		)
		path.addLine(to: CGPoint(x: 0, y: rect.height))

		path.closeSubpath()

		return path
	}
}
