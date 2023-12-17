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

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Saloo")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    lazy var cloudKitContainer: CKContainer = { return CKContainer(identifier: gCloudKitContainerIdentifier)}()
}
