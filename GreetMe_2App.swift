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
    @State var string1: String!
    @State var string2: String!
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            OccassionsMenu(searchType: $string1, noneSearch: $string2, calViewModel: CalViewModel(), showDetailView: ShowDetailView(), oo2: false)
                .environmentObject(appDelegate)
                .environment(\.managedObjectContext, dataController.persistentContainer.viewContext)
        }
    }
}

struct bindingVariables {
    var chosenObject: CoverImageObject!
    var collageImage: CollageImage!
    var noteField: NoteField!
}
