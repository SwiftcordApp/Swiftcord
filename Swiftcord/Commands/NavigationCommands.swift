//
//  NavigationCommands.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 26/5/22.
//

import SwiftUI

struct NavigationCommands: Commands {
    var body: some Commands {
		CommandMenu("Navigation") {
			Button("Previous Server") {}
				.keyboardShortcut(.upArrow, modifiers: [.command, .option])
			Button("Next Server") {}
				.keyboardShortcut(.downArrow, modifiers: [.command, .option])
			
			Divider()
			
			Button("Previous Channel") {}
				.keyboardShortcut(.upArrow, modifiers: [.option])
			Button("Next Channel") {}
				.keyboardShortcut(.downArrow, modifiers: [.option])
			
			Divider()
			
			Button("DMs") {}
				.keyboardShortcut(.rightArrow, modifiers: [.command, .option])
			Button("Create/Join Server") {}
				.keyboardShortcut("N", modifiers: [.command, .shift])
		}
    }
}
