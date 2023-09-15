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
            OnboardingView(
                appName: "Budget Categoriser",
                features: [
                    Feature(title: "Categorise Your Products", description: "Add category for your products", icon: "folder"),
                    Feature(title: "List Your Products", description: "Add products in your categories with financial features", icon: "list.bullet.rectangle"),
                    // Add more features as needed
                ],
                            color: Color.blue // You can change the color to your preferred color
                        )
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(dataStore)
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dataStore)
        }
    }
}

