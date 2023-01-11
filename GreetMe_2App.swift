//
//  GreetMe_2App.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.

import SwiftUI
import CloudKit




@main
struct GreetMe_2App: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            StartMenu(calViewModel: CalViewModel(), showDetailView: ShowDetailView())
                .environment(\.managedObjectContext, persistenceController.persistentContainer.viewContext)
        }
    }
}
