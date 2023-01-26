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
    
    func addCoreCard(noteField: NoteField, chosenOccassion: Occassion, an1: String, an2: String, an2URL: String, an3: String, an4: String, chosenObject: ChosenCoverImageObject, collageImage: CollageImage, context: NSManagedObjectContext, songID: String?, songName: String?, songArtistName: String?, songArtImageData: Data?, songDuration: String?) {
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
            coreCard.collage = collageImage.collageImage.pngData()!
            coreCard.coverImage = chosenObject.coverImage
            coreCard.date = Date.now
            coreCard.font = noteField.font
            coreCard.message = noteField.noteText
            coreCard.songID = songID
            coreCard.songName = songName
            coreCard.songArtistName = songArtistName
            coreCard.songArtImageData = songArtImageData
            coreCard.songDuration = songDuration
            
            
            
            context.save(with: .addCoreCard)
            print("Save Successful")
        }
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
}
