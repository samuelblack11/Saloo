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
    
    func createCardRecord(from coreCard: CoreCard, id: CKRecord.ID, collageImageURL: URL, coverImageURL: URL) -> CKRecord {
        let cardRecord = CKRecord(recordType: "CD_CoreCard", recordID: id)
        // Updating the cardRecord with all fields
        cardRecord["CD_uniqueName"] = coreCard.uniqueName
        cardRecord["CD_date"] = coreCard.date
        cardRecord["CD_font"] = coreCard.font
        cardRecord["CD_message"] = coreCard.message
        cardRecord["CD_an1"] = coreCard.an1
        cardRecord["CD_an2"] = coreCard.an2
        cardRecord["CD_an2URL"] = coreCard.an2URL
        cardRecord["CD_an3"] = coreCard.an3
        cardRecord["CD_an4"] = coreCard.an4
        cardRecord["CD_cardName"] = coreCard.cardName
        cardRecord["CD_occassion"] = coreCard.occassion
        cardRecord["CD_recipient"] = coreCard.recipient
        cardRecord["CD_sender"] = coreCard.sender
        cardRecord["CD_songID"] = coreCard.songID
        cardRecord["CD_spotID"] = coreCard.spotID
        cardRecord["CD_spotName"] = coreCard.spotName
        cardRecord["CD_spotArtistName"] = coreCard.spotArtistName
        cardRecord["CD_songName"] = coreCard.songName
        cardRecord["CD_songArtistName"] = coreCard.songArtistName
        cardRecord["CD_songAlbumName"] = coreCard.songAlbumName
        cardRecord["CD_songArtImageData"] = coreCard.songArtImageData as CKRecordValue?
        cardRecord["CD_songPreviewURL"] = coreCard.songPreviewURL
        cardRecord["CD_songDuration"] = coreCard.songDuration
        cardRecord["CD_inclMusic"] = coreCard.inclMusic
        cardRecord["CD_spotImageData"] = coreCard.spotImageData as CKRecordValue?
        cardRecord["CD_spotSongDuration"] = coreCard.spotSongDuration
        cardRecord["CD_spotPreviewURL"] = coreCard.spotPreviewURL
        cardRecord["CD_songAddedUsing"] = coreCard.songAddedUsing
        cardRecord["CD_cardType"] = coreCard.cardType
        cardRecord["CD_appleAlbumArtist"] = coreCard.appleAlbumArtist
        cardRecord["CD_spotAlbumArtist"] = coreCard.spotAlbumArtist
        cardRecord["CD_salooUserID"] = coreCard.salooUserID
        cardRecord["CD_appleSongURL"] = coreCard.appleSongURL
        cardRecord["CD_spotSongURL"] = coreCard.spotSongURL
        cardRecord["CD_creator"] = coreCard.creator
        cardRecord["CD_unsplashImageURL"] = coreCard.unsplashImageURL
        cardRecord["CD_coverSizeDetails"] = coreCard.coverSizeDetails

        let collageAsset = CKAsset(fileURL: collageImageURL)
        cardRecord["CD_collageAsset"] = collageAsset
        let coverImageAsset = CKAsset(fileURL: coverImageURL)
        cardRecord["CD_coverImageAsset"] = coverImageAsset
        
        return cardRecord

    }
    func addCoreCard(noteField: NoteField, chosenOccassion: Occassion, an1: String, an2: String, an2URL: String, an3: String, an4: String, chosenObject: ChosenCoverImageObject, collageImage: CollageImage, context: NSManagedObjectContext, songID: String?, spotID: String?, spotName: String?, spotArtistName: String?, songName: String?, songArtistName: String?, songAlbumName: String?, songArtImageData: Data?, songPreviewURL: String?, songDuration: String?, inclMusic: Bool, spotImageData: Data?, spotSongDuration: String?, spotPreviewURL: String?, songAddedUsing: String?, cardType: String, appleAlbumArtist: String?, spotAlbumArtist: String?, salooUserID: String, appleSongURL: String?, spotSongURL: String?, completion: @escaping (CoreCard) -> Void) {
        var createdCoreCard: CoreCard!
        PersistenceController.shared.persistentContainer.viewContext.performAndWait {
            let id = CKRecord.ID(recordName: UUID().uuidString)
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
            coreCard.recordID = id.recordName
            coreCard.appleAlbumArtist = appleAlbumArtist
            coreCard.spotAlbumArtist = spotAlbumArtist
            coreCard.cardType = cardType
            coreCard.salooUserID = salooUserID
            coreCard.appleSongURL = appleSongURL
            coreCard.spotSongURL = spotSongURL
            coreCard.unsplashImageURL = chosenObject.smallImageURLString
            coreCard.collage = collageImage.collageImage
            coreCard.coverImage = chosenObject.coverImage
            coreCard.creator = UserDefaults.standard.object(forKey: "SalooUserID") as? String
            let tempDirectory = FileManager.default.temporaryDirectory
            let collageImageURL = tempDirectory.appendingPathComponent(UUID().uuidString)
            let coverImageURL = tempDirectory.appendingPathComponent(UUID().uuidString)
            do {try coreCard.collage!.write(to: collageImageURL)}
            catch {print("Failed to write image data to disk: \(error)")}
            do {try coreCard.coverImage!.write(to: coverImageURL)}
            catch {print("Failed to write image data to disk: \(error)")}
            let cardRecordPublic = createCardRecord(from: coreCard, id: id, collageImageURL: collageImageURL, coverImageURL: coverImageURL)
            let cardRecordPrivate = createCardRecord(from: coreCard, id: id, collageImageURL: collageImageURL, coverImageURL: coverImageURL)
            let publicDatabase = PersistenceController.shared.cloudKitContainer.publicCloudDatabase
            let privateDatabase = PersistenceController.shared.cloudKitContainer.privateCloudDatabase
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "SalooQueueSaveCard")
            queue.async {
                self.saveRecord(with: cardRecordPublic, for: publicDatabase, using: group, fileURL: nil as URL?, fileURL2: nil as URL?)
                group.wait() // Wait for first saveRecord operation to complete
                self.saveRecord(with: cardRecordPrivate, for: privateDatabase, using: group, fileURL: collageImageURL, fileURL2: coverImageURL)
                group.wait() // Wait for second saveRecord operation to complete
                DispatchQueue.main.async {
                    print("Context saved after both CloudKit operations completed")
                    do {try PersistenceController.shared.persistentContainer.viewContext.save(with: .addCoreCard)}
                    catch {print("PERSISTENCE ERROR>>>>>>"); print(error.localizedDescription)}
                    createdCoreCard = coreCard
                    completion(createdCoreCard)
                    print("Save Successful")
                }
            }
        }
    }
        
    
    func saveRecord(with record: CKRecord, for database: CKDatabase, using group: DispatchGroup, fileURL: URL?, fileURL2: URL?) {
        print("Save1")
        group.enter()
        print("Save2")

        // Starting the background task
        var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
        backgroundTaskId = UIApplication.shared.beginBackgroundTask {
            // This block will be executed if your app is about to be terminated by iOS while this task is running
            UIApplication.shared.endBackgroundTask(backgroundTaskId)
            backgroundTaskId = .invalid
        }

        database.save(record) { savedRecord, error in
            defer {
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
                backgroundTaskId = .invalid
            }

            if let error = error {
                //GettingRecord.shared.shareFail = true
                //ErrorMessageViewModel.shared.errorMessage = "\(database.databaseScope == .public ? "Public" : "Private")--------\(error.localizedDescription)"
                print("CloudKit Save Error: \(error.localizedDescription)")
                
            } else {
                //GettingRecord.shared.shareSuccess = true
                //ErrorMessageViewModel.shared.successMessage = "Record Saved Successfully to \(database.databaseScope == .public ? "Public" : "Private") Database!"
                print("Record Saved Successfully to \(database.databaseScope == .public ? "Public" : "Private") Database!")
            }
            
            if fileURL != nil {
                do {try FileManager.default.removeItem(at: fileURL!)}
                catch {print("Failed to remove temporary image file: \(error)")}
                do {try FileManager.default.removeItem(at: fileURL2!)}
                catch {print("Failed to remove temporary image file: \(error)")}
            }
            print("Save3")
            group.leave()
            print("Save4")
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
