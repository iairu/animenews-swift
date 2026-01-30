//
//  animenewsApp.swift
//  animenews
//
//  Created by Ondrej Špánik on 30/01/2026.
//

import SwiftUI

@main
struct animenewsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
