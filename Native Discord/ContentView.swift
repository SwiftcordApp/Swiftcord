//
//  ContentView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var sheetOpen = false
    @State private var guilds: [PartialGuild] = []
    @State private var selectedGuild: Guild? = nil
    
    @StateObject private var gateway = DiscordGateway()

    var body: some View {
        HStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(guilds, id: \.id) { guild in
                        ServerButton(
                            selected: selectedGuild?.id == guild.id,
                            name: guild.name,
                            systemIconName: nil,
                            assetIconName: nil,
                            serverIconURL: nil,
                            bgColor: nil,
                            onSelect: { Task {
                                selectedGuild = await DiscordAPI.getGuild(id: guild.id)
                            }}
                        )
                    }
                }
                .frame(width: 72)
            }.frame(maxHeight: .infinity, alignment: .top)
            
            if selectedGuild != nil {
                ServerView(guild: selectedGuild!)
            }
        }
        .onAppear {
            let _ = gateway.onStateChange.addHandler { (connected, resuming, error) in
                print("Connection state change: \(connected), \(resuming)")
            }
            Task {
                guard let g = await DiscordAPI.getGuilds()
                else { return }
                guilds = g
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


var secondItems = ["Second 1", "Second 2", "Second 3", "Second 4"]

struct SecondView: View {

    var body: some View {
        NavigationView {
        }
    }
}
