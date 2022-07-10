//
//  DataController.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import Foundation
import CoreData
import UIKit
// Created using https://www.hackingwithswift.com/read/38/2/designing-a-core-data-model
// https://www.hackingwithswift.com/read/38/3/adding-core-data-to-our-project-nspersistentcontainer
// https://www.hackingwithswift.com/read/38/4/creating-an-nsmanagedobject-subclass-with-xcode
class DataController: UIResponder, UIApplicationDelegate {
    
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
    

    // ...
    static let shared = DataController()
    
    lazy var container: NSPersistentCloudKitContainer = {
    
        let container2 = NSPersistentCloudKitContainer(name: "GreetMe_2")
        container2.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container2
    }()
    
    var viewContext:NSManagedObjectContext {
        return container.viewContext
    }
    
    // ...
}
    
    //https://developer.apple.com/documentation/coredata/mirroring_a_core_data_store_with_cloudkit/setting_up_core_data_with_cloudkit
   // init() {
        
        //container = NSPersistentContainer(name: "GreetMe_2")
       // container = NSPersistentCloudKitContainer(name: "GreetMe_2")
       // container.loadPersistentStores { storeDescription, error in
       // print("Store Description: \(storeDescription)")
       //     if let error = error {
        //        print("Unresolved error \(error)")
        //    }
       // }
        //backgroundContext = container.newBackgroundContext()
    //}
    
    // https://www.hackingwithswift.com/read/38/3/adding-core-data-to-our-project-nspersistentcontainer
    //func load() {
     //   container.loadPersistentStores { storeDescription, error in
      //      if let error = error {
      //          print("Unresolved error \(error)")
      //      }
      //  }
    //}
