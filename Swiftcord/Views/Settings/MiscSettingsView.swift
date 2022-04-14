//
//  MiscSettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI

struct DebugTableItem: Identifiable {
    let id = UUID()
    let item: String
    let val: String
}

struct MiscSettingsView: View {
    @EnvironmentObject var gateway: DiscordGateway
    @EnvironmentObject var state: UIState
    @AppStorage("miscSettingsSelected") private var selectedLink = "change"

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
            
            DebugTableItem(item: "Loading stage", val: String(describing: state.loadingState)),
        ]
        
        NavigationView {
            List {
                NavigationLink("Change Log", tag: "change", selection: Binding($selectedLink)) {
                    Text("Nothing")
                }
                
                NavigationLink("Hypesquad", tag: "hype", selection: Binding($selectedLink)) {
                    Text("Not hype")
                }
                
                NavigationLink("About", tag: "abt", selection: Binding($selectedLink)) {
                    ScrollView {
                        VStack {
                            Text("")
                        }.padding(40)
                    }
                }
                
                NavigationLink("Debug", tag: "dbg", selection: Binding($selectedLink)) {
                    Table(debugValues) {
                        TableColumn("Item", value: \.item)
                        TableColumn("Value", value: \.val)
                    }
                }
            }.listStyle(SidebarListStyle())
        }
    }
}
