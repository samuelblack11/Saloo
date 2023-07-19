//
//  PersistenceController.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/4/23.
//

import Foundation
import CoreData
import CloudKit
import SwiftUI

let gCloudKitContainerIdentifier = "iCloud.com.Saloo.saloo"

/**
 This app doesn't necessarily post notifications from the main queue.
 */
extension Notification.Name {
    static let cdcksStoreDidChange = Notification.Name("cdcksStoreDidChange")
}

struct UserInfoKey {
    static let storeUUID = "storeUUID"
    static let transactions = "transactions"
}

struct TransactionAuthor {
    static let app = "app"
}

class PersistenceController: NSObject, ObservableObject {
    static let shared = PersistenceController()
    var cloudSharingControllerDelegate: UICloudSharingControllerDelegate?
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let baseURL = NSPersistentContainer.defaultDirectoryURL()
        let storeFolderURL = baseURL.appendingPathComponent("CoreDataStores")
        let publichStoreFolderURL = storeFolderURL.appendingPathComponent("Public")
        let privateStoreFolderURL = storeFolderURL.appendingPathComponent("Private")

        let fileManager = FileManager.default
        for folderURL in [publichStoreFolderURL, privateStoreFolderURL] where !fileManager.fileExists(atPath: folderURL.path) {
            do {try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)}
            catch {fatalError("#\(#function): Failed to create the store folder: \(error)")}
        }

        let container = NSPersistentCloudKitContainer(name: "Saloo")
        guard let publicStoreDescription = container.persistentStoreDescriptions.first else {
            fatalError("#\(#function): Failed to retrieve a persistent store description.")
        }
        publicStoreDescription.url = publichStoreFolderURL.appendingPathComponent("public.sqlite")
        
        publicStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        publicStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        let cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: gCloudKitContainerIdentifier)
        cloudKitContainerOptions.databaseScope = .public
        publicStoreDescription.cloudKitContainerOptions = cloudKitContainerOptions
        
        guard let privateStoreDescription = publicStoreDescription.copy() as? NSPersistentStoreDescription else {
            fatalError("#\(#function): Copying the public store description returned an unexpected value.")
        }
        privateStoreDescription.url = privateStoreFolderURL.appendingPathComponent("private.sqlite")
        
        let privateStoreOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: gCloudKitContainerIdentifier)
        privateStoreOptions.databaseScope = .private
        privateStoreDescription.cloudKitContainerOptions = privateStoreOptions

        /**
         Load the persistent stores.
         */
        container.persistentStoreDescriptions.append(privateStoreDescription)
        container.loadPersistentStores(completionHandler: { (loadedStoreDescription, error) in
            guard error == nil else {
                print("Failed to load persistent stores: \(error)")

                fatalError("#\(#function): Failed to load persistent stores:\(error!)")
            }
            guard let cloudKitContainerOptions = loadedStoreDescription.cloudKitContainerOptions else {
                return
            }
            if cloudKitContainerOptions.databaseScope == .public {
                self._publicPersistentStore = container.persistentStoreCoordinator.persistentStore(for: loadedStoreDescription.url!)
            } else if cloudKitContainerOptions.databaseScope  == .private {
                self._privatePersistentStore = container.persistentStoreCoordinator.persistentStore(for: loadedStoreDescription.url!)
            }
        })

        /**
         Run initializeCloudKitSchema() once to update the CloudKit schema every time you change the Core Data model.
         Don't call this code in the production environment.
         */
        #if InitializeCloudKitSchema
        do {
            try container.initializeCloudKitSchema()
        } catch {
            print("\(#function): initializeCloudKitSchema: \(error)")
        }
        #else
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.transactionAuthor = TransactionAuthor.app

        /**
         Automatically merge the changes from other contexts.
         */
        container.viewContext.automaticallyMergesChangesFromParent = true

        /**
         Pin the viewContext to the current generation token and set it to keep itself up-to-date with local changes.
         */
        do {try container.viewContext.setQueryGenerationFrom(.current)}
        catch { fatalError("#\(#function): Failed to pin viewContext to the current generation:\(error)")}
        /**
         Observe the following notifications:
         - The remote change notifications from container.persistentStoreCoordinator.
         - The .NSManagedObjectContextDidSave notifications from any context.
         - The event change notifications from the container.
         */
        NotificationCenter.default.addObserver(self, selector: #selector(storeRemoteChange(_:)),
                                               name: .NSPersistentStoreRemoteChange,
                                               object: container.persistentStoreCoordinator)
        NotificationCenter.default.addObserver(self, selector: #selector(containerEventChanged(_:)),
                                               name: NSPersistentCloudKitContainer.eventChangedNotification,
                                               object: container)
        #endif
        return container
    }()
    
    private var _privatePersistentStore: NSPersistentStore?
    var privatePersistentStore: NSPersistentStore {return _privatePersistentStore!}
    private var _publicPersistentStore: NSPersistentStore?
    var publicPersistentStore: NSPersistentStore {return _publicPersistentStore!}
    lazy var cloudKitContainer: CKContainer = { return CKContainer(identifier: gCloudKitContainerIdentifier)}()
    lazy var historyQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
