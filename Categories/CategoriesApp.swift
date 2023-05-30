//
//  CategoriesApp.swift
//  Categories
//
//  Created by Batıkan Yılmaz on 11.03.2023.
//

import SwiftUI

@main
struct CategoriesApp: App {
    let persistenceController = PersistenceController.shared
    let dataStore = DataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dataStore)
        }
    }
}
