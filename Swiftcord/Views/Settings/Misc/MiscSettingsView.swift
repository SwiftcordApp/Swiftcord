//
//  MiscSettingsView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 6/3/22.
//

import SwiftUI
import DiscordAPI

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
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 16) {
                                Image(nsImage: NSImage(named: "AppIcon")!).resizable().frame(width: 128, height: 128)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Swiftcord").font(.largeTitle)
                                    Text("A completely native Discord client for macOS built 100% in Swift and SwiftUI. Light on your CPU and RAM.")
                                    Text("Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) (Build: \(Bundle.main.infoDictionary!["CFBundleVersion"] as! String))").font(.caption)
                                }
                                Spacer()
                            }.padding([.horizontal, .top], -20)
                            
                            Divider()
                            
                            Text("Credits").font(.title)
                            VStack(alignment: .center, spacing: 2) {
                                Image(systemName: "person.fill").font(.system(size: 24))
                                Text("Head Developer").font(.title2).padding(.top, 8)
                                Text("Vincent Kwok")
                            }.frame(maxWidth: .infinity)
                            HStack(alignment: .top, spacing: 16) {
                                VStack(alignment: .center, spacing: 2) {
                                    Image(systemName: "person.3").font(.system(size: 24))
                                    Text("Contributors").font(.title2).padding(.top, 8)
                                    Link("Anthony Ingle",
                                         destination: URL(string: "https://github.com/ingleanthony")!)
                                    Link("Ben Tettmar",
                                         destination: URL(string: "https://github.com/bentettmar")!)
									Link("royal",
										 destination: URL(string: "https://github.com/rrroyal")!)
                                    
                                    Text("Big thanks to all contributors <3! Contributions are more than welcome :D")
                                        .padding(.top, 4)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }.frame(maxWidth: .infinity)
                                VStack(alignment: .center, spacing: 2) {
                                    Image(systemName: "dollarsign.circle").font(.system(size: 24))
                                    Text("Sponsors").font(.title2).padding(.top, 8)
                                    Text("Nobody yet...")
                                    
                                    Text("Please sponsor the project on GitHub!")
                                        .padding(.top, 4)
                                        .font(.caption)
                                }.frame(maxWidth: .infinity)
                            }
                            Link(destination: URL(string: "https://www.reddit.com/r/discordapp/comments/k6s89b/i_recreated_the_discord_loading_animation/")!) {
                                Text("Thanks to iJayTD on Reddit for recreating the Discord loading animation and agreeing to its use in Swiftcord!").multilineTextAlignment(.leading)
                            }
                            Text("And finally, thanks to Discord for building such an amazing community and infrastructure!").font(.subheadline)
                            
                            Divider()
                            
                            Text("Swiftcord is open-source software and built with love. You can find its source code in GitHub at the link below! Contributions and issue reports are welcome ;) Please also give Swiftcord a star, it gives me motivation to continue working on it.").font(.headline)
                            Link("Swiftcord on GitHub",
                                 destination: URL(string: "https://github.com/cryptoAlgorithm/Swiftcord")!)
                        }.padding(40)
                    }
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
