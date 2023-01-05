//
//  GreetMe_2App.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.

import SwiftUI
import CloudKit




@main
struct GreetMe_2App: App {
    
    let dataController = CoreDataStack.shared
    let persistenceController = PersistenceController.shared

    @StateObject var cm = CKModel()
    //@UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            //ContentView()
            OccassionsMenu(calViewModel: CalViewModel(), showDetailView: ShowDetailView())
                //.environmentObject(appDelegate)
                //.environment(\.managedObjectContext, dataController.context)
                //.environmentObject(cm)
                //.environment(\.managedObjectContext, CoreDataStack.shared.context)
                .environment(\.managedObjectContext, persistenceController.persistentContainer.viewContext)
        }
    }
}
