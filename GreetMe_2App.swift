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
    @StateObject var cm = CKModel()
    @State var showView = true
    //@UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            OccassionsMenu(calViewModel: CalViewModel(), showDetailView: ShowDetailView(), isShowingOccassions: $showView)
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
