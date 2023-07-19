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
        PersistenceController.shared.persistentContainer.viewContext.performAndWait {
            let id = CKRecord.ID(recordName: UUID().uuidString)
            print("ID....\(id)")
            let cardRecord = CKRecord(recordType: "CD_CoreCard", recordID: id)

            // Updating the cardRecord with all fields
            cardRecord["CD_uniqueName"] = id.recordName
            cardRecord["CD_date"] = Date.now
            cardRecord["CD_font"] = noteField.font
            cardRecord["CD_message"] = noteField.noteText.value
            cardRecord["CD_an1"] = an1
            cardRecord["CD_an2"] = an2
            cardRecord["CD_an2URL"] = an2URL
            cardRecord["CD_an3"] = an3
            cardRecord["CD_an4"] = an4
            cardRecord["CD_cardName"] = noteField.cardName.value
            cardRecord["CD_occassion"] = chosenOccassion.occassion
            cardRecord["CD_recipient"] = noteField.recipient.value
            cardRecord["CD_sender"] = noteField.sender.value
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
            cardRecord["CD_creator"] = UserDefaults.standard.object(forKey: "SalooUserID") as? String
            cardRecord["CD_unsplashImageURL"] = chosenObject.smallImageURLString
            cardRecord["CD_coverSizeDetails"] = chosenObject.coverSizeDetails
            let coreCard = CoreCard(context: context)
            coreCard.coverSizeDetails = chosenObject.coverSizeDetails
            coreCard.uniqueName = id.recordName
            coreCard.cardName = noteField.cardName.value
            coreCard.occassion = chosenOccassion.occassion
            coreCard.recipient = noteField.recipient.value
            coreCard.sender = noteField.sender.value
            coreCard.an1 = an1
            coreCard.an2 = an2
            coreCard.an2URL = an2URL
            coreCard.an3 = an3
            coreCard.an4 = an4
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
            coreCard.unsplashImageURL = chosenObject.smallImageURLString
            
            print("Testing collageAsset...")
            coreCard.collage = collageImage.collageImage
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent(UUID().uuidString)
            do {try collageImage.collageImage.write(to: fileURL)}
            catch {print("Failed to write image data to disk: \(error)")}
            let collageAsset = CKAsset(fileURL: fileURL)
            cardRecord["CD_collageAsset"] = collageAsset
            coreCard.creator = UserDefaults.standard.object(forKey: "SalooUserID") as? String
            let publicDatabase = PersistenceController.shared.cloudKitContainer.publicCloudDatabase
            let privateDatabase = PersistenceController.shared.cloudKitContainer.privateCloudDatabase
            let group = DispatchGroup()
            saveRecord(with: cardRecord, for: publicDatabase, using: group, fileURL: fileURL)
            //saveRecord(with: cardRecord, for: privateDatabase, using: group, fileURL: fileURL)
            group.notify(queue: .main) {
                print("Context saved after both CloudKit operations completed")
                do {try PersistenceController.shared.persistentContainer.viewContext.save(with: .addCoreCard)}
                catch {print("PERSISTENCE ERROR>>>>>>"); print(error.localizedDescription)}
                createdCoreCard = coreCard
                completion(createdCoreCard)
                print("Save Successful")
            }
        }
    }
    
    func saveRecord(with record: CKRecord, for database: CKDatabase, using group: DispatchGroup, fileURL: URL?) {
        group.enter()
        database.save(record) { savedRecord, error in
            if let error = error {print("CloudKit Save Error: \(error.localizedDescription)")}
            else {print("Record Saved Successfully to \(database.databaseScope == .public ? "Public" : "Private") Database!")}
            if fileURL != nil {
                do {try FileManager.default.removeItem(at: fileURL!)}
                catch {print("Failed to remove temporary image file: \(error)")}
            }
            group.leave()
        }
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
