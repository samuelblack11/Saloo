//
//  CoreDataHelper.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/4/23.
//

import Foundation
import CoreData
import CloudKit

extension NSPersistentStore {
    func contains(manageObject: NSManagedObject) -> Bool {
        let objectID = manageObject.objectID
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: manageObject.entity.name!)
        fetchRequest.predicate = NSPredicate(format: "self == %@", objectID)
        fetchRequest.affectedStores = [self]
        
        if let context = manageObject.managedObjectContext,
           let result = try? context.count(for: fetchRequest), result > 0 {
            return true
        }
        return false
    }
}

extension NSManagedObject {
    var persistentStore: NSPersistentStore? {
        guard let context = self.managedObjectContext,
              let persistentStoreCoordinator = context.persistentStoreCoordinator,
              let persistentStore = persistentStoreCoordinator.persistentStores.first(where: { $0.contains(manageObject: self) })
        else {
            return nil
        }
        return persistentStore
    }
}


extension NSManagedObjectContext {
    /**
     Contextual information for handling errors that occur when saving a managed object context.
     */
    enum ContextualInfoForSaving: String {
        case addCoreCard, deleteCoreCard
        case toggleTagging, deleteTag, addTag
        case addRating, deleteRating
        case sheetOnDismiss
        case deduplicateAndWait
    }
    /**
     Save a context and handle the save error. This sample simply prints the error message. Real apps can
     implement comprehensive error handling based on the contextual information.
     */
    func save(with contextualInfo: ContextualInfoForSaving) {
        if hasChanges {
            do {
                try save()
                print("CoreDataContextSave successful")
            } catch {
                print("\(#function): Failed to save Core Data context for \(contextualInfo.rawValue): \(error)")
            }
        }
    }
}

/**
 A convenience method for creating background contexts that specify the app as their transaction author.
 */
extension NSPersistentCloudKitContainer {
    func newTaskContext() -> NSManagedObjectContext {
        let context = newBackgroundContext()
        context.transactionAuthor = TransactionAuthor.app
        return context
    }
    
    /**
     Fetch and return shares in the persistent stores.
     */
    func fetchShares(in persistentStores: [NSPersistentStore]) throws -> [CKShare] {
        var results = [CKShare]()
        for persistentStore in persistentStores {
            do {
                let shares = try fetchShares(in: persistentStore)
                results += shares
            } catch let error {
                print("Failed to fetch shares in \(persistentStore).")
                throw error
            }
        }
        return results
    }
}

