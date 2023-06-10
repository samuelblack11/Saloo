//
//  PersistenceController+Card.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/4/23.
//
import Foundation
import CoreData
import CloudKit
import SwiftUI

extension PersistenceController {
    
    func createZoneIfNeeded(zoneName: String, completion: @escaping () -> Void) {
        let zoneID = CKRecordZone.ID(zoneName: zoneName, ownerName: CKCurrentUserDefaultName)
        let fetchZonesOperation = CKFetchRecordZonesOperation(recordZoneIDs: [zoneID])
        
        fetchZonesOperation.fetchRecordZonesCompletionBlock = { zonesByID, error in
            if let error = error {
                print("Error fetching zone: \(error)")

                // The zone does not exist, so we create it.
                let zone = CKRecordZone(zoneID: zoneID)
                let operation = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: [])
                
                operation.modifyRecordZonesCompletionBlock = { (saved, deleted, error) in
                    if let error = error {
                        print("Error creating zone: \(error)")
                    } else {
                        print("Successfully created zone")
                        completion()
                    }
                }
                self.cloudKitContainer.privateCloudDatabase.add(operation)
            } else {
                print("Zone already exists")
                completion()
            }
        }
        cloudKitContainer.privateCloudDatabase.add(fetchZonesOperation)
    }

    
    func addCoreCard(noteField: NoteField, chosenOccassion: Occassion, an1: String, an2: String, an2URL: String, an3: String, an4: String, chosenObject: ChosenCoverImageObject, collageImage: CollageImage, context: NSManagedObjectContext, songID: String?, spotID: String?, spotName: String?, spotArtistName: String?, songName: String?, songArtistName: String?, songAlbumName: String?, songArtImageData: Data?, songPreviewURL: String?, songDuration: String?, inclMusic: Bool, spotImageData: Data?, spotSongDuration: String?, spotPreviewURL: String?, songAddedUsing: String?, cardType: String, appleAlbumArtist: String?, spotAlbumArtist: String?, salooUserID: String, completion: @escaping (CoreCard) -> Void) {
        var createdCoreCard: CoreCard!
            context.performAndWait {
                print("running addCoreCard now...")
                let recordZone = CKRecordZone(zoneName: "Cards")
                let id = CKRecord.ID(zoneID: recordZone.zoneID)
                let cardRecord = CKRecord(recordType: "Card", recordID: id)
                let coreCard = CoreCard(context: context)
                coreCard.uniqueName = UUID().uuidString
                coreCard.cardName = noteField.cardName.value
                coreCard.occassion = chosenOccassion.occassion
                coreCard.recipient = noteField.recipient.value
                coreCard.sender = noteField.sender.value
                coreCard.associatedRecord = cardRecord
                coreCard.an1 = an1
                coreCard.an2 = an2
                coreCard.an2URL = an2URL
                coreCard.an3 = an3
                coreCard.an4 = an4
                coreCard.collage = collageImage.collageImage
                coreCard.coverImage = chosenObject.coverImage
                coreCard.date = Date.now
                coreCard.font = noteField.font
                coreCard.message = noteField.noteText.value
                coreCard.songID = songID
                coreCard.songName = songName
                coreCard.songArtistName = songArtistName
                coreCard.songAlbumName = songAlbumName
                coreCard.songArtImageData = songArtImageData
                coreCard.songPreviewURL = songPreviewURL
                coreCard.songDuration = songDuration
                coreCard.inclMusic = inclMusic
                coreCard.spotID = spotID
                coreCard.spotName = spotName
                coreCard.spotArtistName = spotArtistName
                coreCard.spotImageData = spotImageData
                coreCard.spotSongDuration = spotSongDuration
                coreCard.spotPreviewURL = spotPreviewURL
                coreCard.songAddedUsing = songAddedUsing
                coreCard.collage1 = collageImage.image1
                coreCard.collage2 = collageImage.image2
                coreCard.collage3 = collageImage.image3
                coreCard.collage4 = collageImage.image4
                coreCard.recordID = UUID().uuidString
                coreCard.appleAlbumArtist = appleAlbumArtist
                coreCard.spotAlbumArtist = spotAlbumArtist
                coreCard.cardType = cardType
                coreCard.salooUserID = salooUserID
                PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
                    coreCard.creator = (ckRecordID?.recordName)!
                }
                    let share = CKShare(rootRecord: cardRecord)
                    share[CKShare.SystemFieldKey.title] = "A Greeting from Saloo"
                    share[CKShare.SystemFieldKey.thumbnailImageData] = coreCard.coverImage
                    coreCard.sharedRecordRootID = share.recordID.recordName
                    share.publicPermission = .readWrite
                let operation = CKModifyRecordsOperation(recordsToSave: [cardRecord, share], recordIDsToDelete: [])
                operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                    if let error = error {
                        print("Error saving records: \(error)")
                        completion(createdCoreCard) // Call completion with the createdCoreCard in error scenarios
                    } else {
                        print("Successfully saved records")
                        do {
                            try context.save()
                            createdCoreCard = coreCard

                            if let savedShare = savedRecords?.first(where: { $0.recordType == "cloudkit.share" }) as? CKShare {
                                // Fetch the CKShare object separately
                                let zoneID = savedShare.recordID.zoneID
                                print("Shared Zone ID: \(zoneID)")
                                print("Shared Zone ID: \(zoneID.zoneName)")
                                createdCoreCard.sharedZoneID = "\(zoneID.zoneName)@@@\(zoneID.ownerName)"
                                completion(createdCoreCard)
                            } else {
                                completion(createdCoreCard)
                            }
                        } catch {
                            print("Failed to save context: \(error)")
                            completion(createdCoreCard) // Call completion with the createdCoreCard in error scenarios
                        }
                    }
                }
                self.cloudKitContainer.privateCloudDatabase.add(operation)
            }
        }

    
    func createShare(coreCard: CoreCard) {
        let recordZone = CKRecordZone(zoneName: "Cards")
        let id = CKRecord.ID(zoneID: recordZone.zoneID)
        let shareID = CKRecord.ID(recordName: UUID().uuidString, zoneID: recordZone.zoneID)
        var share = CKShare(rootRecord: coreCard.associatedRecord, shareID: shareID)
        share[CKShare.SystemFieldKey.title] = "A Greeting, from GreetMe"
        share[CKShare.SystemFieldKey.thumbnailImageData] = coreCard.coverImage
        share.publicPermission = .readWrite
        
        let modifyRecordsOp = CKModifyRecordsOperation(recordsToSave: [share, coreCard.associatedRecord])
    }

    func deleteCoreCard(card: CoreCard) {
        if let context = card.managedObjectContext {
            context.perform {
                context.delete(card)
                context.save(with: .deleteCoreCard)
            }
        }
    }
    
    func cardTransactions(from notification: Notification) -> [NSPersistentHistoryTransaction] {
        var results = [NSPersistentHistoryTransaction]()
        if let transactions = notification.userInfo?[UserInfoKey.transactions] as? [NSPersistentHistoryTransaction] {
            let cardEntityName = CoreCard.entity().name
            for transaction in transactions where transaction.changes != nil {
                for change in transaction.changes! where change.changedObjectID.entity.name == cardEntityName {
                    results.append(transaction)
                    break // Jump to the next transaction.
                }
            }
        }
        return results
    }
    
    
    func updateRecordWithSpotData(for coreCard: CoreCard, in context: NSManagedObjectContext, spotName: String, spotArtistName: String, spotID: String, spotImageData: Data, spotSongDuration: String, completion: @escaping (Error?) -> Void) {
        let controller = PersistenceController.shared
        let taskContext = controller.persistentContainer.newTaskContext()
        let ckContainer = PersistenceController.shared.cloudKitContainer
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        var database: CKDatabase?
        // Add the query operation to the desired database
        PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
            if coreCard.creator == (ckRecordID?.recordName)! {database = ckContainer.privateCloudDatabase}
            else {database = ckContainer.sharedCloudDatabase}
        }
        
        let recordID = coreCard.associatedRecord.recordID
        database?.fetch(withRecordID: recordID) { (record, error) in
            guard let record = record else {
                // Handle error - failed to fetch record
                completion(error)
                return
            }
            // Process the fetched record
            print("Fetched record with ID: \(record.recordID.recordName)")
            record.setValue(spotName, forKey: "CD_spotName")
            record.setValue(spotArtistName, forKey: "CD_spotArtistName")
            record.setValue(spotID, forKey: "CD_spotID")
            record.setValue(spotImageData, forKey: "CD_spotImageData")
            record.setValue(spotSongDuration, forKey: "CD_spotSongDuration")
            // Save changes to Core Data
            do {try context.save()}
            catch {
                completion(error)
                return
            }
            // Save changes to CloudKit
            database!.save(record) { (record, error) in
                if let error = error {
                    // Handle error
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
    }
    
    
    func updateRecordWithAMData(for coreCard: CoreCard, in context: NSManagedObjectContext, songName: String, songArtistName: String, songID: String, songImageData: Data, songDuration: String, completion: @escaping (Error?) -> Void) {
        let controller = PersistenceController.shared
        let taskContext = controller.persistentContainer.newTaskContext()
        let ckContainer = PersistenceController.shared.cloudKitContainer
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        var database: CKDatabase?
        // Add the query operation to the desired database
        PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
            if coreCard.creator == (ckRecordID?.recordName)! {
                print("Set to private db")
                database = ckContainer.privateCloudDatabase
            }
            else {
                print("Set to shared db")
                database = ckContainer.sharedCloudDatabase
            }
            
            
            let recordID = CKRecord.ID(recordName: coreCard.sharedRecordRootID!)
            print("@@@")
            print(recordID)
            print("about to run fetch...")
            database?.fetch(withRecordID: recordID) { (record, error) in
                print("----")
                print(record)
                print(error)
                
                
                guard let record = record else {
                    // Handle error - failed to fetch record
                    print("***Failed to fetch record")
                    print(error?.localizedDescription)
                    completion(error)
                    return
                }
                // Process the fetched record
                print("Fetched record with ID: \(record.recordID.recordName)")
                record.setValue(songName, forKey: "CD_songName")
                record.setValue(songArtistName, forKey: "CD_songArtistName")
                record.setValue(songID, forKey: "CD_songID")
                record.setValue(songImageData, forKey: "CD_songImageData")
                record.setValue(songDuration, forKey: "CD_songDuration")
                // Save changes to Core Data
                do {try context.save()}
                catch {
                    print("***Failed to save core data")
                    print(error.localizedDescription)
                    completion(error)
                    return
                }
                // Save changes to CloudKit
                database!.save(record) { (record, error) in
                    if let error = error {
                        // Handle error
                        print("***Failed to save record")
                        print(error.localizedDescription)
                        completion(error)
                        return
                    }
                    completion(nil)
                }
            }
        }
    }
}

