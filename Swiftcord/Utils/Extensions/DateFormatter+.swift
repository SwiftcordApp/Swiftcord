//
//  DateFormatter+.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 16/7/22.
//

import Foundation

extension DateFormatter {
	static var messageDateFormatter: DateFormatter = {
		let fmt = DateFormatter()
		fmt.dateStyle = .short
		fmt.timeStyle = .short
		fmt.doesRelativeDateFormatting = true
		return fmt
	}()
}
