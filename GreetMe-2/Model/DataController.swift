//
//  DataController.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import Foundation
import CoreData
import UIKit
import CloudKit
// Created using https://www.hackingwithswift.com/read/38/2/designing-a-core-data-model
// https://www.hackingwithswift.com/read/38/3/adding-core-data-to-our-project-nspersistentcontainer
// https://www.hackingwithswift.com/read/38/4/creating-an-nsmanagedobject-subclass-with-xcode

//https://developer.apple.com/documentation/coredata/mirroring_a_core_data_store_with_cloudkit/setting_up_core_data_with_cloudkit
// https://www.hackingwithswift.com/read/38/3/adding-core-data-to-our-project-nspersistentcontainer
//https://www.raywenderlich.com/29934862-sharing-core-data-with-cloudkit-in-swiftui

class DataController: UIResponder, UIApplicationDelegate, ObservableObject {
    
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
    var viewContext:NSManagedObjectContext {
        return container.viewContext
    }
    
    private var _privatePersistentStore: NSPersistentStore?
    private var _sharedPersistentStore: NSPersistentStore?
    //private init() {}
    var privatePersistentStore: NSPersistentStore {
      guard let privateStore = _privatePersistentStore else {
        fatalError("Private store is not set")
      }
      return privateStore
    }

    var sharedPersistentStore: NSPersistentStore {
      guard let sharedStore = _sharedPersistentStore else {
        fatalError("Shared store is not set")
      }
      return sharedStore
    }
    // This is needed as the second parameter in CloudSharingView
    var ckContainer: CKContainer {
      let storeDescription = container.persistentStoreDescriptions.first
      guard let identifier = storeDescription?
        .cloudKitContainerOptions?.containerIdentifier else {
        fatalError("Unable to get container identifier")
      }
      return CKContainer(identifier: identifier)
    }
    
    static let shared = DataController()
    
    lazy var container: NSPersistentCloudKitContainer = {
        let container2 = NSPersistentCloudKitContainer(name: "GreetMe_2")

        guard let privateStoreDescription = container2.persistentStoreDescriptions.first else {
            fatalError("Unable to get persistentStoreDescription")
        }
        let storesURL = privateStoreDescription.url?.deletingLastPathComponent()
        privateStoreDescription.url = storesURL?.appendingPathComponent("private.sqlite")
        // This configures the shared database to store records shared with you.
        let sharedStoreURL = storesURL?.appendingPathComponent("shared.sqlite")
        guard let sharedStoreDescription = privateStoreDescription
          .copy() as? NSPersistentStoreDescription else {
          fatalError(
            "Copying the private store description returned an unexpected value."
          )
        }
        sharedStoreDescription.url = sharedStoreURL
        // This creates NSPersistentContainerCLoudKitContainerOptions using the identifier from your private store description.
        guard let containerIdentifier = privateStoreDescription
          .cloudKitContainerOptions?.containerIdentifier else {
          fatalError("Unable to get containerIdentifier")
        }
        let sharedStoreOptions = NSPersistentCloudKitContainerOptions(
          containerIdentifier: containerIdentifier
        )
        sharedStoreOptions.databaseScope = .shared
        sharedStoreDescription.cloudKitContainerOptions = sharedStoreOptions
        
        //Adds Description to Container
        container2.persistentStoreDescriptions.append(sharedStoreDescription)
        
        //Store a reference to each store when it's loaded. It checks the database scope and determines whether its private or shared
        container.loadPersistentStores { loadedStoreDescription, error in
          if let error = error as NSError? {
            fatalError("Failed to load persistent stores: \(error)")
          } else if let cloudKitContainerOptions = loadedStoreDescription
            .cloudKitContainerOptions {
            guard let loadedStoreDescritionURL = loadedStoreDescription.url else {
              return
            }
            if cloudKitContainerOptions.databaseScope == .private {
              let privateStore = container2.persistentStoreCoordinator
                .persistentStore(for: loadedStoreDescritionURL)
              self._privatePersistentStore = privateStore
            } else if cloudKitContainerOptions.databaseScope == .shared {
              let sharedStore = container2.persistentStoreCoordinator
                .persistentStore(for: loadedStoreDescritionURL)
              self._sharedPersistentStore = sharedStore
            }
          }
        }
        
       // container2.loadPersistentStores(completionHandler: {
       //     (storeDescription, error) in
       //     if let error = error as NSError? {
       //         fatalError("Unresolved error \(error), \(error.userInfo)")
       //     }
       // })
        
        return container2
    }()
}

// This is teh code related to sharing. It checks the persistentStore of the NSManagedObjectID that was passed in to see if it's the sharedPersistentStore. If it is, the object is already shared. Otherwise, it uses fetchShares to see if there are any records with a matching objectID
extension DataController {
  private func isShared(objectID: NSManagedObjectID) -> Bool {
    var isShared = false
    if let persistentStore = objectID.persistentStore {
      if persistentStore == sharedPersistentStore {
        isShared = true
      } else {
        let container2 = container
        do {
          let shares = try container2.fetchShares(matching: [objectID])
          if shares.first != nil {
            isShared = true
          }
        } catch {
          print("Failed to fetch share for \(objectID): \(error)")
        }
      }
    }
    return isShared
  }
    
func isShared(object: NSManagedObject) -> Bool {
    isShared(objectID: object.objectID)
    }
}
