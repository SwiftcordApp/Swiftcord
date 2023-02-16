//
//  NSTextView+.swift
//  Swiftcord
//
//  Created by royal on 14/05/2022.
//

import AppKit

extension NSTextView {

	/// Sets NSTextView background to clear, allowing setting background of TextEditor.
	override open var frame: CGRect {
		didSet {
			backgroundColor = .clear
			drawsBackground = true
		}
	}

	/// Gets rid of over-the-top focus indicator.
	override open var focusRingType: NSFocusRingType {
		get { .none }
		set { }
	}

}
