//
//  DebugSettingsVieq.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 4/6/22.
//

import SwiftUI
import DiscordKit
import DiscordKitCore

struct DebugTableItem: Identifiable {
	let id = UUID()
	let item: String
	let val: String
}

struct DebugSettingsView: View {
	@EnvironmentObject var gateway: DiscordGateway
	@EnvironmentObject var state: UIState

    var body: some View {
		let debugValues = [
			/*DebugTableItem(item: "Gateway connected", val: gateway.isConnected.toString()),
			DebugTableItem(item: "Gateway reconnecting", val: gateway.isReconnecting.toString()),
			DebugTableItem(item: "Gateway cannot resume", val: gateway.doNotResume.toString()),
			DebugTableItem(item: "Gateway sequence #", val: String(gateway.seq ?? 0)),
			// DebugTableItem(item: "Gateway viability", val: gateway.viability.toString()),
			DebugTableItem(item: "Gateway connection #", val: String(gateway.connTimes)),
			DebugTableItem(item: "Gateway session ID", val: gateway.sessionID ?? "nil"),
			DebugTableItem(item: "Gateway missed heartbeat ACKs", val: String(gateway.missedACK)),*/

			DebugTableItem(item: "Gateway session established", val: gateway.connected.toString()),
			DebugTableItem(item: "Network reachable", val: gateway.reachable.toString()),
			DebugTableItem(item: "Loading stage", val: String(describing: state.loadingState)),
			DebugTableItem(item: "Base URL", val: GatewayConfig.default.baseURL),
			DebugTableItem(item: "REST API base URL", val: GatewayConfig.default.restBase),
			DebugTableItem(item: "Gateway URL", val: GatewayConfig.default.gateway)
		]

		VStack(spacing: 0) {
			Table(debugValues) {
				TableColumn("Item", value: \.item)
				TableColumn("Value", value: \.val)
			}.frame(height: 150)
			Divider()
			ScrollView {
				VStack(alignment: .leading, spacing: 16) {
					Text("settings.others.debug.actions").font(.largeTitle)
					Text("settings.others.debug.actions.info")

					Button("settings.others.debug.actions.crash", role: .destructive) {
						let funny: Int? = nil
						print(funny!)
					}
					.buttonStyle(FlatButtonStyle())
					.controlSize(.small)
				}
				.padding()
				.frame(maxWidth: .infinity, alignment: .leading)
			}
		}
    }
}
