//
//  GreetMe_2App.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
// https://developer.apple.com/forums/thread/658242

import SwiftUI
import CloudKit

@main
struct GreetMe_2App: App {
    
    let dataController = CoreDataStack.shared
    @State var string1: String!
    @State var string2: String!
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    //var sceneDelegate: SceneDelegate
    //let sceneDelegate = UIApplication.shared.delegate as! SceneDelegate
    // sceneDelegate.ownerOpeningOwnShare
    @State var ownerOpeningOwnShare = true

    var body: some Scene {
        WindowGroup {
            computedView()
        }
    }
    
    
    func computedView() -> some View {
        if ownerOpeningOwnShare {
            return AnyView(OpenOwnerShare())
        }
        else {
            return AnyView(OccassionsMenu(searchType: $string1, noneSearch: $string2, calViewModel: CalViewModel(), showDetailView: ShowDetailView())
                .environment(\.managedObjectContext, dataController.persistentContainer.viewContext))
        }
    }
}

struct bindingVariables {
    var chosenObject: CoverImageObject!
    var collageImage: CollageImage!
    var noteField: NoteField!
}
