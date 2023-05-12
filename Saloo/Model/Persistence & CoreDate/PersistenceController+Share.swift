//
//  PersistenceController+Share.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/4/23.
//

import Foundation
import CoreData
import UIKit
import CloudKit
//https://www.reddit.com/r/SwiftUI/comments/qfs8x3/im_trying_to_present_a_share_sheet_but_it_doesnt/
#if os(iOS) // UICloudSharingController is only available in iOS.
// MARK: - Convenient methods for managing sharing.
//
extension PersistenceController {
    func presentCloudSharingController(coreCard: CoreCard) {
        /**
         Grab the share if the photo is already shared.
         */
        var coreCardShare: CKShare?
        if let shareSet = try? persistentContainer.fetchShares(matching: [coreCard.objectID]),
           let (_, share) = shareSet.first {
            print("ShareSetFirst is true")
            coreCardShare = share
        }

        let sharingController: UICloudSharingController
        if coreCardShare == nil {
            print("coreCardShare is nil")
            print(coreCard)
            var counter = 0
            while counter < 5 {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    
                }
                counter += 1
                print("Counter = \(counter)")
            }
            
            
                    sharingController = newSharingController(unsharedCoreCard: coreCard, persistenceController: self)
                } else {
                    print("coreCardShare not nil")
                    sharingController = UICloudSharingController(share: coreCardShare!, container: cloudKitContainer)
                }
                sharingController.delegate = self
                /**
                 Setting the presentation style to .formSheet so there's no need to specify sourceView, sourceItem, or sourceRect.
                 */
                guard var topVC = UIApplication.shared.windows.first?.rootViewController else {
                    return
                }
                while let presentedVC = topVC.presentedViewController {topVC = presentedVC }
                    sharingController.modalPresentationStyle = .formSheet
                    topVC.present(sharingController, animated: true)
                }
            
    
    func presentCloudSharingController(share: CKShare) {
        let sharingController = UICloudSharingController(share: share, container: cloudKitContainer)
        sharingController.delegate = self
        /**
         Setting the presentation style to .formSheet so there's no need to specify sourceView, sourceItem, or sourceRect.
         */
        if let viewController = rootViewController {
            sharingController.modalPresentationStyle = .formSheet
            viewController.present(sharingController, animated: true)
        }
    }
    
    private func newSharingController(unsharedCoreCard: CoreCard, persistenceController: PersistenceController) -> UICloudSharingController {
        let sharingController = UICloudSharingController { (controller, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Called new sharing controller...")
            /**
             The app doesn't specify a share intentionally, so Core Data creates a new share (zone).
             CloudKit has a limit on how many zones a database can have, so this app provides an option for users to use an existing share.
             
             If the share's publicPermission is CKShareParticipantPermissionNone, only private participants can accept the share.
             Private participants mean the participants an app adds to a share by calling CKShare.addParticipant.
             If the share is more permissive, and is, therefore, a public share, anyone with the shareURL can accept it,
             or self-add themselves to it.
             The default value of publicPermission is CKShare.ParticipantPermission.none.
             */
            
            
            self.persistentContainer.share([unsharedCoreCard], to: nil) { objectIDs, share, container, error in
                print("Beginning share completion handler...")
                if let share = share {
                    print("Share = Share")
                    self.configure(share: share)
                    // Set the available permissions to an empty set to load the share into the sharing controller
                    controller.availablePermissions = []
                }
                print("Called share completion")
                print(share)
                print(container)
                print(error)
                
                completion(share, container, error)
            }
            }
        }
        return sharingController
    }

        
    
    
    
    private func newSharingController(sharedRootRecord: CKRecord,
                                      database: CKDatabase,
                                      completionHandler: @escaping (UICloudSharingController?) -> Void) {
        let shareRecordID = sharedRootRecord.share!.recordID
        let fetchRecordsOp = CKFetchRecordsOperation(recordIDs: [shareRecordID])

        fetchRecordsOp.fetchRecordsCompletionBlock = { recordsByRecordID, error in
            guard handleCloudKitError(error, operation: .fetchRecords, affectedObjects: [shareRecordID]) == nil,
                let share = recordsByRecordID?[shareRecordID] as? CKShare else {
                return
            }
            
            DispatchQueue.main.async {
                let sharingController = UICloudSharingController(share: share, container: self.cloudKitContainer)
                completionHandler(sharingController)
            }
        }
        database.add(fetchRecordsOp)
    }

    private var rootViewController: UIViewController? {
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive,
               let sceneDeleate = (scene as? UIWindowScene)?.delegate as? UIWindowSceneDelegate,
               let window = sceneDeleate.window {
                return window?.rootViewController
            }
        }
        print("\(#function): Failed to retrieve the window's root view controller.")
        return nil
    }
}

extension PersistenceController: UICloudSharingControllerDelegate {
    /**
     CloudKit triggers the delegate method in two cases:
     - An owner stops sharing a share.
     - A participant removes themselves from a share by tapping the Remove Me button in UICloudSharingController.
     
     After stopping the sharing,  purge the zone or just wait for an import to update the local store.
     This sample chooses to purge the zone to avoid stale UI. That triggers a "zone not found" error because UICloudSharingController
     deletes the zone, but the error doesn't really matter in this context.
     
     Purging the zone has a caveat:
     - When sharing an object from the owner side, Core Data moves the object to the shared zone.
     - When calling purgeObjectsAndRecordsInZone, Core Data removes all the objects and records in the zone.
     To keep the objects, deep copy the object graph you want to keep and make sure no object in the new graph is associated with any share.
     
     The purge API posts an NSPersistentStoreRemoteChange notification after finishing its job, so observe the notification to update
     the UI, if necessary.
     */
    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        if let share = csc.share {
            purgeObjectsAndRecords(with: share)
        }
    }

    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        if let share = csc.share, let persistentStore = share.persistentStore {
            persistentContainer.persistUpdatedShare(share, in: persistentStore) { (share, error) in
                if let error = error {
                    print("\(#function): Failed to persist updated share: \(error)")
                }
            }
        }
    }

    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("\(#function): Failed to save a share: \(error)")
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return csc.share?.title ?? "A cool photo"
    }
}
#endif

extension PersistenceController {
    
    func shareObject(_ unsharedObject: NSManagedObject, to existingShare: CKShare?,
                     completionHandler: ((_ share: CKShare?, _ error: Error?) -> Void)? = nil)
    {
        persistentContainer.share([unsharedObject], to: existingShare) { (objectIDs, share, container, error) in
            guard error == nil, let share = share else {
                print("\(#function): Failed to share an object: \(error!))")
                completionHandler?(share, error)
                return
            }
            /**
             Deduplicate tags, if necessary, because adding a photo to an existing share moves the whole object graph to the associated
             record zone, which can lead to duplicated tags.
             */

            if existingShare != nil {
                if let tagObjectIDs = objectIDs?.filter({ $0.entity.name == "CoreCard" }), !tagObjectIDs.isEmpty {
                    //self.deduplicateAndWait(tagObjectIDs: Array(tagObjectIDs))
                }
            } else {
                self.configure(share: share)
            }
            /**
             Synchronize the changes on the share to the private persistent store.
             */

            self.persistentContainer.persistUpdatedShare(share, in: self.privatePersistentStore) { (share, error) in
                if let error = error {
                    print("\(#function): Failed to persist updated share: \(error)")
                }
                completionHandler?(share, error)
            }
        }
    }
    
    /**
     Delete the Core Data objects and the records in the CloudKit record zone associated with the share.
     */
    func purgeObjectsAndRecords(with share: CKShare, in persistentStore: NSPersistentStore? = nil) {
        guard let store = (persistentStore ?? share.persistentStore) else {
            print("\(#function): Failed to find the persistent store for share. \(share))")
            return
        }
        persistentContainer.purgeObjectsAndRecordsInZone(with: share.recordID.zoneID, in: store) { (zoneID, error) in
            if let error = error {
                print("\(#function): Failed to purge objects and records: \(error)")
            }
        }
    }

    func existingShare(coreCard: CoreCard) -> CKShare? {
        if let shareSet = try? persistentContainer.fetchShares(matching: [coreCard.objectID]),
           let (_, share) = shareSet.first {
            return share
        }
        return nil
    }
    
    func share(with title: String) -> CKShare? {
        let stores = [privatePersistentStore, sharedPersistentStore]
        let shares = try? persistentContainer.fetchShares(in: stores)
        let share = shares?.first(where: { $0.title == title })
        return share
    }
    
    func shareTitles() -> [String] {
        let stores = [privatePersistentStore, sharedPersistentStore]
        let shares = try? persistentContainer.fetchShares(in: stores)
        return shares?.map { $0.title } ?? []
    }
    
    private func configure(share: CKShare, with coreCard: CoreCard? = nil) {
        print("Did configure?")
        share[CKShare.SystemFieldKey.title] = "A Greeting, from Saloo"
        share[CKShare.SystemFieldKey.thumbnailImageData] = coreCard?.coverImage
        share.publicPermission = .readOnly
        //share.recordID = coreCard?.associatedRecord.recordID
        //share.recordID = coreCard?.associatedRecord
        print("Did configure")
    }
}

extension PersistenceController {
    func addParticipant(emailAddress: String, permission: CKShare.ParticipantPermission = .readWrite, share: CKShare,
                        completionHandler: ((_ share: CKShare?, _ error: Error?) -> Void)?) {
        /**
         Use the email address to look up the participant from the private store. Return if the participant doesn't exist.
         Use privatePersistentStore directly because only the owner may add participants to a share.
         */
        let lookupInfo = CKUserIdentity.LookupInfo(emailAddress: emailAddress)
        let persistentStore = privatePersistentStore //share.persistentStore!

        persistentContainer.fetchParticipants(matching: [lookupInfo], into: persistentStore) { (results, error) in
            guard let participants = results, let participant = participants.first, error == nil else {
                completionHandler?(share, error)
                return
            }
                  
            participant.permission = permission
            participant.role = .privateUser
            share.addParticipant(participant)
            
            self.persistentContainer.persistUpdatedShare(share, in: persistentStore) { (share, error) in
                if let error = error {
                    print("\(#function): Failed to persist updated share: \(error)")
                }
                completionHandler?(share, error)
            }
        }
    }
    
    func deleteParticipant(_ participants: [CKShare.Participant], share: CKShare,
                           completionHandler: ((_ share: CKShare?, _ error: Error?) -> Void)?) {
        for participant in participants {
            share.removeParticipant(participant)
        }
        /**
         Use privatePersistentStore directly because only the owner may delete participants to a share.
         */
        persistentContainer.persistUpdatedShare(share, in: privatePersistentStore) { (share, error) in
            if let error = error {
                print("\(#function): Failed to persist updated share: \(error)")
            }
            completionHandler?(share, error)
        }
    }
}

extension CKShare.ParticipantAcceptanceStatus {
    var stringValue: String {
        return ["Unknown", "Pending", "Accepted", "Removed"][rawValue]
    }
}

extension CKShare {
    var title: String {
        guard let date = creationDate else {
            return "Share-\(UUID().uuidString)"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return "Share-" + formatter.string(from: date)
    }
    
    var persistentStore: NSPersistentStore? {
        let persistentContainer = PersistenceController.shared.persistentContainer
        let privatePersistentStore = PersistenceController.shared.privatePersistentStore
        if let shares = try? persistentContainer.fetchShares(in: privatePersistentStore) {
            let zoneIDs = shares.map { $0.recordID.zoneID }
            if zoneIDs.contains(recordID.zoneID) {
                return privatePersistentStore
            }
        }
        let sharedPersistentStore = PersistenceController.shared.sharedPersistentStore
        if let shares = try? persistentContainer.fetchShares(in: sharedPersistentStore) {
            let zoneIDs = shares.map { $0.recordID.zoneID }
            if zoneIDs.contains(recordID.zoneID) {
                return sharedPersistentStore
            }
        }
        return nil
    }
}

