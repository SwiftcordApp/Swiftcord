//
//  MiscSettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI
import DiscordKit

struct DebugTableItem: Identifiable {
    let id = UUID()
    let item: String
    let val: String
}

struct MiscSettingsView: View {
    @EnvironmentObject var gateway: DiscordGateway
    @EnvironmentObject var state: UIState
	@State private var selectedLink: SidebarLink? = .changelog

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
            DebugTableItem(item: "Gateway URL", val: GatewayConfig.default.gateway),
        ]
        
        NavigationView {
			List {
				NavigationLink("Change Log", tag: SidebarLink.changelog, selection: $selectedLink) {
                    Text("Nothing")
                }
                
				NavigationLink("Hypesquad", tag: SidebarLink.hype, selection: $selectedLink) {
                    Text("Not hype")
                }
                
				NavigationLink("About", tag: SidebarLink.about, selection: $selectedLink) {
                    AboutSwiftcordView()
                }
                
				NavigationLink("Debug", tag: SidebarLink.debug, selection: $selectedLink) {
                    Table(debugValues) {
                        TableColumn("Item", value: \.item)
                        TableColumn("Value", value: \.val)
                    }
                }
            }.listStyle(SidebarListStyle())
        }
    }
}

private extension MiscSettingsView {
	enum SidebarLink {
		case changelog
		case hype
		case about
		case debug
	}
}
