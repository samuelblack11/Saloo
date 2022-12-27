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
    @StateObject var cm = CKModel()
    @StateObject var viewTransitions = ViewTransitions()
    //@UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            OccassionsMenu(calViewModel: CalViewModel(), showDetailView: ShowDetailView(), viewTransitions: viewTransitions)
                //.environmentObject(appDelegate)
                //.environment(\.managedObjectContext, dataController.context)
                .environmentObject(cm)

        }
    }
}

struct bindingVariables {
    var chosenObject: CoverImageObject!
    var collageImage: CollageImage!
    var noteField: NoteField!
}
