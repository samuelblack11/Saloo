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
    
    func addCoreCard(noteField: NoteField, chosenOccassion: Occassion, an1: String, an2: String, an2URL: String, an3: String, an4: String, chosenObject: ChosenCoverImageObject, collageImage: CollageImage, context: NSManagedObjectContext, songID: String?, spotID: String?, spotName: String?, spotArtistName: String?, songName: String?, songArtistName: String?, songAlbumName: String?, songArtImageData: Data?, songPreviewURL: String?, songDuration: String?, inclMusic: Bool, spotImageData: Data?, spotSongDuration: String?, spotPreviewURL: String?, songAddedUsing: String?, cardType: String, appleAlbumArtist: String?, spotAlbumArtist: String?, salooUserID: String, appleSongURL: String?, spotSongURL: String?, completion: @escaping (CoreCard) -> Void) {
        var createdCoreCard: CoreCard!
        context.performAndWait {
            print("Apple Album Artist is....\(appleAlbumArtist)")
            print("Collage Data:    \(collageImage.collageImage)")
            
            let id = CKRecord.ID(recordName: UUID().uuidString)
            print("ID....\(id)")
            let cardRecord = CKRecord(recordType: "Card", recordID: id)
            
            // Updating the cardRecord with all fields
            cardRecord["CD_an1"] = an1
            cardRecord["CD_an2"] = an2
            cardRecord["CD_an2URL"] = an2URL
            cardRecord["CD_an3"] = an3
            cardRecord["CD_an4"] = an4
            // More fields...
            cardRecord["CD_cardName"] = noteField.cardName.value
            cardRecord["CD_occassion"] = chosenOccassion.occassion
            cardRecord["CD_recipient"] = noteField.recipient.value
            cardRecord["CD_sender"] = noteField.sender.value
            // More fields...
            cardRecord["CD_songID"] = songID
            cardRecord["CD_spotID"] = spotID
            cardRecord["CD_spotName"] = spotName
            cardRecord["CD_spotArtistName"] = spotArtistName
            cardRecord["CD_songName"] = songName
            cardRecord["CD_songArtistName"] = songArtistName
            cardRecord["CD_songAlbumName"] = songAlbumName
            cardRecord["CD_songArtImageData"] = songArtImageData as CKRecordValue?
            cardRecord["CD_songPreviewURL"] = songPreviewURL
            cardRecord["CD_songDuration"] = songDuration
            cardRecord["CD_inclMusic"] = inclMusic
            cardRecord["CD_spotImageData"] = spotImageData as CKRecordValue?
            cardRecord["CD_spotSongDuration"] = spotSongDuration
            cardRecord["CD_spotPreviewURL"] = spotPreviewURL
            cardRecord["CD_songAddedUsing"] = songAddedUsing
            cardRecord["CD_cardType"] = cardType
            cardRecord["CD_appleAlbumArtist"] = appleAlbumArtist
            cardRecord["CD_spotAlbumArtist"] = spotAlbumArtist
            cardRecord["CD_salooUserID"] = salooUserID
            cardRecord["CD_appleSongURL"] = appleSongURL
            cardRecord["CD_spotSongURL"] = spotSongURL
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
            coreCard.recordID = cardRecord.recordID.recordName
            coreCard.appleAlbumArtist = appleAlbumArtist
            coreCard.spotAlbumArtist = spotAlbumArtist
            coreCard.cardType = cardType
            coreCard.salooUserID = salooUserID
            coreCard.appleSongURL = appleSongURL
            coreCard.spotSongURL = spotSongURL
            PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
                coreCard.creator = (ckRecordID?.recordName)!
            }
            
            
            let publicDatabase = PersistenceController.shared.cloudKitContainer.publicCloudDatabase
            publicDatabase.save(cardRecord) { (record, error) in
                if let error = error {
                    print("CloudKit Save Error: \(error.localizedDescription)")
                } else {
                    print("Record Saved Successfully!")
                }
            }
            context.save(with: .addCoreCard)
            createdCoreCard = coreCard
            completion(createdCoreCard)
            print("Save Successful")
            print(coreCard.collage)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func convertCoreCardToCodable(coreCard: CoreCard) -> CodableCoreCard {
        return CodableCoreCard(
            id: coreCard.uniqueName,  // Assuming the uniqueName is being used as an id
            cardName: coreCard.cardName,
            occassion: coreCard.occassion,
            recipient: coreCard.recipient,
            sender: coreCard.sender,
            an1: coreCard.an1,
            an2: coreCard.an2,
            an2URL: coreCard.an2URL,
            an3: coreCard.an3,
            an4: coreCard.an4,
            collage: coreCard.collage,
            coverImage: coreCard.coverImage,
            date: coreCard.date,
            font: coreCard.font,
            message: coreCard.message,
            uniqueName: coreCard.uniqueName,
            songID: coreCard.songID,
            spotID: coreCard.spotID,
            spotName: coreCard.spotName,
            spotArtistName: coreCard.spotArtistName,
            songName: coreCard.songName,
            songArtistName: coreCard.songArtistName,
            songArtImageData: coreCard.songArtImageData,
            songPreviewURL: coreCard.songPreviewURL,
            songDuration: coreCard.songDuration,
            inclMusic: coreCard.inclMusic,
            spotImageData: coreCard.spotImageData,
            spotSongDuration: coreCard.spotSongDuration,
            spotPreviewURL: coreCard.spotPreviewURL,
            creator: coreCard.creator,
            songAddedUsing: coreCard.songAddedUsing,
            collage1: coreCard.collage1,
            collage2: coreCard.collage2,
            collage3: coreCard.collage3,
            collage4: coreCard.collage4,
            cardType: coreCard.cardType,
            recordID: coreCard.recordID,
            songAlbumName: coreCard.songAlbumName,
            appleAlbumArtist: coreCard.appleAlbumArtist,
            spotAlbumArtist: coreCard.spotAlbumArtist,
            salooUserID: coreCard.salooUserID,
            sharedRecordID: coreCard.sharedRecordID,
            appleSongURL: coreCard.appleSongURL,
            spotSongURL: coreCard.spotSongURL
        )
    }
    func loadCoreCards() -> [CoreCard] {
        let request = CoreCard.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        var cardsFromCore: [CoreCard] = []
        var filteredCards: [CoreCard] = []
        do {
            cardsFromCore = try PersistenceController.shared.persistentContainer.viewContext.fetch(request)
            //print("START MENU Got \(cardsFromCore.count) Cards From Core")
        }
        catch {print("Fetch failed")}
        return cardsFromCore
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

extension UIViewController {
    var topmostViewController: UIViewController {
        return presentedViewController?.topmostViewController ?? self
    }
}
