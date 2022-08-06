//
//  GreetMe_2App.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import SwiftUI

@main
struct GreetMe_2App: App {
    let dataController = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            //LoginView()
            MenuView(calViewModel: CalViewModel(), showDetailView: ShowDetailView())
                .environment(\.managedObjectContext, dataController.persistentContainer.viewContext)
        }
    }
}

struct bindingVariables {
    var chosenObject: CoverImageObject!
    var collageImage: CollageImage!
    var noteField: NoteField!
}
