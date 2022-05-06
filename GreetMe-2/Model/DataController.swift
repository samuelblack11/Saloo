//
//  DataController.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import Foundation
import CoreData
// Created using https://www.hackingwithswift.com/read/38/2/designing-a-core-data-model
// https://www.hackingwithswift.com/read/38/3/adding-core-data-to-our-project-nspersistentcontainer
// https://www.hackingwithswift.com/read/38/4/creating-an-nsmanagedobject-subclass-with-xcode
class DataController {
    
    // Load the container once here, so it can be used elsewhere in the app
    // NSPersistentContainer allows for the following:
    // 1. Load (Greetings) model and created NSManagedObjectModel object from it
    // 2. Create an NSPersistentStoreCoordinator object, which is responsible for reading from and writing to disk
    // 3. Set up a URL pointing ot the database on disk where our actual saved obejcts live.
    // 4. Load the database into the NSPersistentStoreCoordinator so it knows where we want it to save.
    // 5. Create an NSManagedObjectContext and point it at the persistent store coordinator
    //var container: NSPersistentContainer!
    // Creates the persistent container and name must match name of .xc... file
    
    // if the database exists, loadPersistentStores will load it. If does not exist, this line will create it
    
    static let shared = DataController()

    
    let container: NSPersistentContainer
    let backgroundContext:NSManagedObjectContext!

    var viewContext:NSManagedObjectContext {
        return container.viewContext
    }
    
    init() {
        container = NSPersistentContainer(name: "GreetMe_2")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        backgroundContext = container.newBackgroundContext()
    }
    
    // https://www.hackingwithswift.com/read/38/3/adding-core-data-to-our-project-nspersistentcontainer
    func load() {
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
}
