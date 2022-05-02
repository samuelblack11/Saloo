//
//  GreetMe_2App.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import SwiftUI

@main
struct GreetMe_2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            //LoginView()
            MenuView()
            //OccassionsMenu()
            //CollageStyleMenu()
            //CollageOneView()
            //CollageTwoView()
            //CollageThreeView()
            //CollageFourView()
            //CollageFiveView()
            //CollageSixView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
