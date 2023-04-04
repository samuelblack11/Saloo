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
    
    func addCoreCard(noteField: NoteField, chosenOccassion: Occassion, an1: String, an2: String, an2URL: String, an3: String, an4: String, chosenObject: ChosenCoverImageObject, collageImage: CollageImage, context: NSManagedObjectContext, songID: String?, spotID: String?, songName: String?, songArtistName: String?, songAlbumName: String?, songArtImageData: Data?, songPreviewURL: String?, songDuration: String?, inclMusic: Bool, spotImageData: Data?, spotSongDuration: String?, spotPreviewURL: String?, songAddedUsing: String?, cardType: String) {
        context.perform {
            
            let recordZone = CKRecordZone(zoneName: "Cards")
            let id = CKRecord.ID(zoneID: recordZone.zoneID)
            let cardRecord = CKRecord(recordType: "Card", recordID: id)
            let coreCard = CoreCard(context: context)
            coreCard.uniqueName = UUID().uuidString
            coreCard.cardName = noteField.cardName
            coreCard.occassion = chosenOccassion.occassion
            coreCard.recipient = noteField.recipient
            coreCard.sender = noteField.sender
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
            coreCard.message = noteField.noteText
            coreCard.songID = songID
            coreCard.songName = songName
            coreCard.songArtistName = songArtistName
            coreCard.songAlbumName = songAlbumName
            coreCard.songArtImageData = songArtImageData
            coreCard.songPreviewURL = songPreviewURL
            coreCard.songDuration = songDuration
            coreCard.inclMusic = inclMusic
            coreCard.spotID = spotID
            coreCard.spotImageData = spotImageData
            coreCard.spotSongDuration = spotSongDuration
            coreCard.spotPreviewURL = spotPreviewURL
            coreCard.songAddedUsing = songAddedUsing
            coreCard.collage1 = collageImage.image1
            coreCard.collage2 = collageImage.image2
            coreCard.collage3 = collageImage.image3
            coreCard.collage4 = collageImage.image4
            coreCard.recordID = UUID().uuidString
            coreCard.cardType = cardType
            PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
                coreCard.creator = (ckRecordID?.recordName)!
            }
            context.save(with: .addCoreCard)
            print("Save Successful")
            //self.createShare(coreCard: coreCard)
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
    
    
    func shareRecord() {
        
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
    

    func updateRecordWithSpotData(for coreCard: CoreCard, in context: NSManagedObjectContext, with database: CKDatabase, spotID: String, spotImageData: Data, spotPreviewURL: String, spotSongDuration: String, completion: @escaping (Error?) -> Void) {
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
        
        // Specify the field and value to search for
        let fieldName = "CD_uniqueName"
        let searchValue = coreCard.uniqueName
        // Create the predicate to use in the query
        let predicate = NSPredicate(format: "%K == %@", fieldName, searchValue)
        // Create the query object with the desired record type and predicate
        let query = CKQuery(recordType: "CD_CoreCard", predicate: predicate)
        // Create the query operation with the query and desired results limit
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.resultsLimit = 1 // Limit to only one result (optional)
        // Set the block to be called when each record is fetched
        queryOperation.recordFetchedBlock = { (record) in
            // Process the fetched record
            print("Fetched record with ID: \(record.recordID.recordName)")
            record.setValue(spotID, forKey: "CD_spotID")
            record.setValue(spotImageData, forKey: "CD_spotImageData")
            record.setValue(spotPreviewURL, forKey: "CD_spotPreviewURL")
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

        // Set the block to be called when the query is complete
        queryOperation.queryCompletionBlock = { (cursor, error) in
            guard error == nil else {
                print("Error fetching records: \(error!.localizedDescription)")
                return
            }
            // Optionally process any cursor information
            if let cursor = cursor {
                print("Query operation completed with cursor: \(cursor)")
            }
        }

        
        database!.add(queryOperation)
        
        
        }
    }
