//
//  SettingsActionRow.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 9/5/23.
//

import SwiftUI

@available(macOS 13.0, *)
struct SettingsActionRow<Dest>: View where Dest: View {
	let label: String
	let iconSystemName: String
	@ViewBuilder let destination: Dest

	private struct ActionRowContent<Child>: View where Child: View {
		let windowTitle: String
		@ViewBuilder let content: Child

		@Environment(\.dismiss) var dismissPresentation

		var body: some View {
			Form {
				content
			}
			.formStyle(.grouped)
			.toolbar {
				ToolbarItem(placement: .navigation) {
					Button {
						dismissPresentation()
					} label: {
						Image(systemName: "chevron.left")
					}
				}
			}
			.navigationTitle("")
			.removeSidebarToggle()
		}
	}

    var body: some View {
		NavigationLink {
			ActionRowContent(windowTitle: label) { destination }
		} label: {
			HStack {
				Image(systemName: iconSystemName)
					.foregroundColor(.primary)
					.frame(width: 20, height: 20)
					.background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(.gray.gradient))
				Text(label)
			}
			.frame(height: 22)
		}
    }
}
