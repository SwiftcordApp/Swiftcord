//
//  Native_DiscordApp.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import SwiftUI

@main
struct Native_DiscordApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
