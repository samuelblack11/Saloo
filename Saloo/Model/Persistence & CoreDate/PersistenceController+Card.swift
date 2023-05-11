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
    
    func addCoreCard(noteField: NoteField, chosenOccassion: Occassion, an1: String, an2: String, an2URL: String, an3: String, an4: String, chosenObject: ChosenCoverImageObject, collageImage: CollageImage, context: NSManagedObjectContext, songID: String?, spotID: String?, spotName: String?, spotArtistName: String?, songName: String?, songArtistName: String?, songAlbumName: String?, songArtImageData: Data?, songPreviewURL: String?, songDuration: String?, inclMusic: Bool, spotImageData: Data?, spotSongDuration: String?, spotPreviewURL: String?, songAddedUsing: String?, cardType: String, appleAlbumArtist: String?, spotAlbumArtist: String?, completion: @escaping (CoreCard) -> Void) {
        var createdCoreCard: CoreCard!
        context.performAndWait {
            
            print("Apple Album Artist is....\(appleAlbumArtist)")
            
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
            PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
                coreCard.creator = (ckRecordID?.recordName)!
            }
            
            context.save(with: .addCoreCard)
            createdCoreCard = coreCard
            completion(createdCoreCard)
            //return createdCoreCard
            print("Save Successful")
        }
        //print("2nd Return Statement")
        //return createdCoreCard
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
    

    func updateRecordWithSpotData(for coreCard: CoreCard, in context: NSManagedObjectContext, with database: CKDatabase, spotName: String, spotArtistName: String, spotID: String, spotImageData: Data, spotSongDuration: String, completion: @escaping (Error?) -> Void) {
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
        
        
        
        if database != nil {database!.add(queryOperation); print("Added data points to CKRecord...")}
        else {print("Couldn't add data points to CKRecord....")}
        }
    


    func updateRecordWithAMData(for coreCard: CoreCard, in context: NSManagedObjectContext, with database: CKDatabase, songName: String, songArtistName: String, songID: String, songImageData: Data, songDuration: String, completion: @escaping (Error?) -> Void) {
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
        record.setValue(songName, forKey: "CD_songName")
        record.setValue(songArtistName, forKey: "CD_songArtistName")
        record.setValue(songID, forKey: "CD_songID")
        record.setValue(songImageData, forKey: "CD_songImageData")
        record.setValue(songDuration, forKey: "CD_songDuration")
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
        if database != nil {database!.add(queryOperation); print("Added data points to CKRecord....")}
        else{print("Couldn't add data points to CKRecord....")}
    }
}

