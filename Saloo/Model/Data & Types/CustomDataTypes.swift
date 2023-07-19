//
//  CustomDataTypes.swift
//  GreetMe-2
//
//  Created by Sam Black on 12/24/22.
//

import Foundation
import UIKit
import SwiftUI
import CloudKit
import Network
import Security
import MessageUI

struct ChosenCollection {@State var occassion: String!; @State var collectionID: String!}
class ChosenCoreCard: ObservableObject {
    static let shared = ChosenCoreCard()
    @Published var chosenCard: CoreCard? = nil
    
}
class Occassion: ObservableObject {
    static let shared = Occassion()
    @Published var occassion = String(); @Published var collectionID = String()
    
}
public class ShowDetailView: ObservableObject {
    static let shared = ShowDetailView()
    @Published public var showDetailView: Bool = false}
class TaskToken: ObservableObject {@Published var taskToken = String()}


class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}


struct SongForList: Hashable {
     var id: String
     var name: String
     var artistName: String
     var albumName: String
     var artImageData: Data
     var durationInMillis: Int
     var isPlaying: Bool
     var previewURL: String
     var disc_number: Int?
     var url: String
}

struct SelectedSong {
    @State var id: String?
    @State var name: String?
    @State var artistName: String?
    @State var artImageData: Data?
    @State var isPlaying: Bool?
    @State var durationInMillis: Int
}

struct UserResponseParent: Codable {
    let usersList: [UserResponse]
}

struct UserResponse: Codable {
    let users: [User]
}

struct User: Codable {
    let partitionKey: String
    let rowKey: String
    let isBanned: Bool
}



class CoreCardWrapper: ObservableObject {
    @Published var enableShare = false
    @Published var coreCard = CoreCard()
}


class ScreenManager: ObservableObject {
    static let shared = ScreenManager()
    // The range of IDs to cycle through
    let ids = Array(1...5)
    // The current index in the ID array
    @Published var currentIndex = 0

    var currentId: Int { ids[currentIndex] }

    func advance() {
        print("Pre-Advance Index \(currentIndex)")
        currentIndex = (currentIndex + 1) % ids.count
        print("Post-Advance Index \(currentIndex)")
    }
}






class CardsForDisplay: ObservableObject {
    static let shared = CardsForDisplay()
    @Published var inboxCards: [CoreCard] = []
    @Published var outboxCards: [CoreCard] = []
    @Published var draftboxCards: [CoreCard] = []
    @Published var userID = UserDefaults.standard.object(forKey: "SalooUserID") as? String
    @Published var isLoading = false
    let privateDatabase = PersistenceController.shared.cloudKitContainer.privateCloudDatabase
    let group = DispatchGroup()
    
    func addCoreCard(card: CoreCard, box: InOut.SendReceive, record: CKRecord?) {
        print("Adding card with uniqueName: \(card.uniqueName)")
        switch box {
        case .inbox:
            print("Current cards in inbox:")
            self.inboxCards.forEach { print($0.uniqueName) }
            if !self.inboxCards.contains(where: { $0.uniqueName == card.uniqueName }) {
                self.inboxCards.append(card)
                self.parseRecord(record: record) { (coreCard, record) in
                    if coreCard != nil {
                        self.saveContext()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.coreCardToRecord(card: coreCard!) { record2 in
                                self.saveRecord(with: record2!, for: PersistenceController.shared.cloudKitContainer.privateCloudDatabase)
                                print("Record parsed and saved successfully")
                            }
                        }
                    }
                }
                
            }
        case .outbox:
            print("Current cards in outbox:")
            self.outboxCards.forEach { print($0.uniqueName) }
            if !self.outboxCards.contains(where: { $0.uniqueName == card.uniqueName }) {
                self.outboxCards.append(card)
            }
        case .draftbox:
            print("Current cards in draftbox:")
            self.draftboxCards.forEach { print($0.uniqueName) }
            if !self.draftboxCards.contains(where: { $0.uniqueName == card.uniqueName }) {
                self.draftboxCards.append(card)
            }
        default:
            print("Invalid box type")
        }
    }
    
    func saveRecord(with record: CKRecord, for database: CKDatabase) {
        database.save(record) { savedRecord, error in
            if let error = error {print("CloudKit Save Error: \(error.localizedDescription)")}
            else {print("Record Saved Successfully to \(database.databaseScope == .public ? "Public" : "Private") Database!")}
        }
    }
    
    
    func deleteCoreCard(card: CoreCard, box: InOut.SendReceive) {
        if box == .outbox {deleteFromDB(uniqueName: card.uniqueName, dataBase: PersistenceController.shared.cloudKitContainer.publicCloudDatabase)}
        deleteFromDB(uniqueName: card.uniqueName, dataBase: PersistenceController.shared.cloudKitContainer.privateCloudDatabase)
        let context = PersistenceController.shared.persistentContainer.viewContext
        print("DELETING \(card.message)")
        print("DELETING \(card.uniqueName)")
        context.delete(card)
        do {try context.save(); print("Successfully deleted card from Core Data and saved context.")}
        catch {print("Error saving context after deleting: \(error)")}
        switch box {
        case .inbox:
            if let index = self.inboxCards.firstIndex(of: card) {
                self.inboxCards.remove(at: index)
            }
        case .outbox:
            if let index = self.outboxCards.firstIndex(of: card) {
                self.outboxCards.remove(at: index)
            }
        case .draftbox:
            if let index = self.draftboxCards.firstIndex(of: card) {
                self.draftboxCards.remove(at: index)
            }
        }
    }
    
    func deleteFromDB(uniqueName: String, dataBase: CKDatabase) {
        print("Called deleteFromPublic")
        let predicate = NSPredicate(format: "CD_uniqueName == %@", uniqueName)
        let query = CKQuery(recordType: "CD_CoreCard", predicate: predicate)
        
        dataBase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { result in
                switch result {
                case .success(let (matchResults, _)):
                    matchResults.forEach { (recordID, fetchResult) in
                        switch fetchResult {
                        case .success(let record):
                            dataBase.delete(withRecordID: record.recordID) { _, error in
                                if let error = error {print("Error deleting record: \(error)")}
                                else {print("Successfully deleted record from CloudKit.")}
                            }
                        case .failure(let error):
                            print("Error fetching individual record: \(error)")
                        }
                    }
                case .failure(let error):
                    print("Error fetching records: \(error)")
                }
            }
    }


    
    func syncCloudKitAndCoreData() {
        print("Called syncCloudKitAndCoreData")
        let privateDatabase = PersistenceController.shared.cloudKitContainer.privateCloudDatabase
        let publicDatabase = PersistenceController.shared.cloudKitContainer.publicCloudDatabase
        
        syncPrivateDatabaseWithCoreData(database: privateDatabase)
        syncPublicDatabaseWithCoreData(database: publicDatabase)
    }

    
    func syncPrivateDatabaseWithCoreData(database: CKDatabase) {
        print("DATABASE")
        print(database.databaseScope.rawValue)
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_CoreCard", predicate: predicate)

        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("CloudKit fetch error: \(error.localizedDescription)")
                return
            }
            print("Check1")
            guard let records = records else { return }

            // Fetch all uniqueNames from CloudKit and filter out empty ones
            let cloudKitUniqueNames = records.compactMap { ($0["CD_uniqueName"] as? String, $0.recordID) }
            let validCloudKitUniqueNames = cloudKitUniqueNames.filter { uniqueName, _ in !uniqueName!.isEmpty }
            
            // Fetch all uniqueNames from Core Data
            let request = CoreCard.createFetchRequest()

            do {
                let cardsFromCore = try PersistenceController.shared.persistentContainer.viewContext.fetch(request)

                // Filter out cards with empty uniqueName
                let validCardsFromCore = cardsFromCore.filter { !$0.uniqueName.isEmpty }

                let coreDataUniqueNames = validCardsFromCore.map { $0.uniqueName }
                print("Check2")
                print(coreDataUniqueNames)
                
                // Find uniqueNames that exist in CloudKit but not in Core Data and delete them
                for (uniqueName, recordID) in validCloudKitUniqueNames where !coreDataUniqueNames.contains(uniqueName!) {
                    database.delete(withRecordID: recordID) { (recordID, error) in
                        if let error = error {print("Failed to delete record: \(error)")}
                        else {print("Deleted record: \(recordID?.recordName ?? "unknown")")}
                    }
                }
                print("Check3")
                
                // Find Core Data records that don't exist in CloudKit and upload them
                for card in validCardsFromCore where !validCloudKitUniqueNames.map({ $0.0 }).contains(card.uniqueName) {
                    print("Check4")
                    print(card.uniqueName)
                    self.coreCardToRecord(card: card) { cardRecord in
                        self.saveRecord(with: cardRecord!, for: database)
                    }
                }

            } catch {
                print("Core Data fetch error: \(error)")
            }
        }
    }

    func syncPublicDatabaseWithCoreData(database: CKDatabase) {
        guard let currentUserID = UserDefaults.standard.object(forKey: "SalooUserID") as? String else {
            print("User ID not found")
            return
        }
        
        print("PUBLIC DATABASE")
        print(database.databaseScope.rawValue)
        let predicate = NSPredicate(format: "CD_salooUserID = %@", currentUserID)
        let query = CKQuery(recordType: "CD_CoreCard", predicate: predicate)

        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("CloudKit fetch error: \(error.localizedDescription)")
                return
            }
            guard let records = records else { return }

            // Fetch all uniqueNames from CloudKit for the current user and filter out empty ones
            let cloudKitUniqueNames = records.compactMap { ($0["CD_uniqueName"] as? String, $0.recordID) }
            let validCloudKitUniqueNames = cloudKitUniqueNames.filter { uniqueName, _ in !uniqueName!.isEmpty }
            
            // Fetch all uniqueNames from Core Data for the current user
            let request = CoreCard.createFetchRequest()
            request.predicate = NSPredicate(format: "salooUserID = %@", currentUserID)

            do {
                let cardsFromCore = try PersistenceController.shared.persistentContainer.viewContext.fetch(request)

                // Filter out cards with empty uniqueName
                let validCardsFromCore = cardsFromCore.filter { !$0.uniqueName.isEmpty }

                let coreDataUniqueNames = validCardsFromCore.map { $0.uniqueName }
                
                // Find uniqueNames that exist in CloudKit but not in Core Data and delete them
                for (uniqueName, recordID) in validCloudKitUniqueNames where !coreDataUniqueNames.contains(uniqueName!) {
                    database.delete(withRecordID: recordID) { (recordID, error) in
                        if let error = error {print("Failed to delete record: \(error)")}
                        else {print("Deleted record: \(recordID?.recordName ?? "unknown")")}
                    }
                }
                
                // Find Core Data records that don't exist in CloudKit and upload them
                for card in validCardsFromCore where !validCloudKitUniqueNames.map({ $0.0 }).contains(card.uniqueName) {
                    self.coreCardToRecord(card: card) { cardRecord in
                        self.saveRecord(with: cardRecord!, for: database)
                    }
                }

            } catch {
                print("Core Data fetch error: \(error)")
            }
        }
    }




    func coreCardToRecord(card: CoreCard, completion: @escaping (CKRecord?) -> Void) {
        let recordID = CKRecord.ID(recordName: card.uniqueName)
        let record = CKRecord(recordType: "CD_CoreCard", recordID: recordID)
        print("Check5")
        record["CD_occassion"] = card.occassion
        record["CD_recipient"] = card.recipient
        record["CD_sender"] = card.sender
        record["CD_an1"] = card.an1
        record["CD_an2"] = card.an2
        record["CD_an2URL"] = card.an2URL
        record["CD_an3"] = card.an3
        record["CD_an4"] = card.an4
        record["CD_date"] = card.date
        record["CD_font"] = card.font
        record["CD_message"] = card.message
        record["CD_songID"] = card.songID
        record["CD_spotID"] = card.spotID
        record["CD_songName"] = card.songName
        record["CD_spotName"] = card.spotName
        record["CD_songArtistName"] = card.songArtistName
        record["CD_spotArtistName"] = card.spotArtistName
        record["CD_songArtImageData"] = card.songArtImageData
        record["CD_songPreviewURL"] = card.songPreviewURL
        record["CD_songDuration"] = card.songDuration
        record["CD_inclMusic"] = card.inclMusic
        record["CD_spotImageData"] = card.spotImageData
        record["CD_spotSongDuration"] = card.spotSongDuration
        record["CD_spotPreviewURL"] = card.spotPreviewURL
        record["CD_songAlbumName"] = card.songAlbumName
        record["CD_spotAlbumArtist"] = card.spotAlbumArtist
        record["CD_appleAlbumArtist"] = card.appleAlbumArtist
        record["CD_creator"] = card.creator
        record["CD_songAddedUsing"] = card.songAddedUsing
        record["CD_cardName"] = card.cardName
        record["CD_cardType"] = card.cardType
        record["CD_appleSongURL"] = card.appleSongURL
        record["CD_spotSongURL"] = card.spotSongURL
        record["CD_uniqueName"] = card.uniqueName
        record["CD_salooUserID"] = card.salooUserID
        record["CD_coverSizeDetails"] = card.coverSizeDetails
        record["CD_unsplashImageURL"] = card.unsplashImageURL
        print("Check6")
        if let collage = card.collage {
            let temporaryDirectoryURL = FileManager.default.temporaryDirectory
            let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString)
            do {
                try collage.write(to: fileURL, options: .atomic)
                record["CD_collageAsset"] = CKAsset(fileURL: fileURL)
            } catch {
                print("Failed to write data to file: \(error)")
            }
        }
        completion(record)
    }
    
    func fetchFromCloudKit() {
          let privateDatabase = PersistenceController.shared.cloudKitContainer.privateCloudDatabase
          let predicate = NSPredicate(value: true) // Fetches all records
          let query = CKQuery(recordType: "CD_CoreCard", predicate: predicate)
          privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
              if let error = error {
                  print("CloudKit fetch error: \(error.localizedDescription)")
              } else if let records = records {
                  let group = DispatchGroup()
                  for record in records {
                      print("RECORD......")
                      print(record)
                      group.enter()
                      self.parseRecord(record: record) { (coreCard, record) in
                          if coreCard != nil {
                              self.saveContext()
                              print("Record parsed and saved successfully")
                          }
                          group.leave()
                      }
                  }
                  group.notify(queue: .main) { print("All records fetched and parsed")}
              }
              else {print("No records returned from CloudKit")}
          }
      }

    func saveContext() {
        let context = PersistenceController.shared.persistentContainer.viewContext
        do {try context.save()}
        catch {print("Error saving context: \(error)")}
    }

    func needToLoadCards() -> Bool {
        var needToLoad = Bool()
        var cardCount = self.inboxCards.count + self.outboxCards.count + self.draftboxCards.count
        if cardCount > 0 {needToLoad = false}
        else {needToLoad = true}
        return needToLoad
    }
    
    
    
    func loadCoreCards(completion: @escaping () -> Void) {
        print("LoadCoreCards called...")
        print(self.inboxCards)
        isLoading = true
        let request = CoreCard.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        if userID == nil {userID = UserSession.shared.salooID}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            do {
                let cardsFromCore = try PersistenceController.shared.persistentContainer.viewContext.fetch(request)
                let validCardsFromCore = cardsFromCore.filter { $0.uniqueName != "" && $0.unsplashImageURL != nil && $0.coverSizeDetails != nil && $0.collage != nil && $0.salooUserID != nil}
                self.outboxCards = validCardsFromCore.filter {card in return self.userID!.contains(card.salooUserID!)}
                self.inboxCards = validCardsFromCore.filter { !self.outboxCards.contains($0) }
                self.isLoading = false
                completion()
            }
            catch {
                print("Fetch failed")
                self.isLoading = false
                completion()
            }
            //}
        }
    }

    func parseRecord(record: CKRecord?, completion: @escaping (CoreCard?, CKRecord?) -> Void) {
        guard let record = record else {
            print("Invalid record.")
            completion(nil, nil)
            return
        }
        let context = PersistenceController.shared.persistentContainer.viewContext
        let coreCard = CoreCard(context: context)
        print("Parsing Record....")
        DispatchQueue.main.async() {
            coreCard.occassion = record.object(forKey: "CD_occassion") as! String
            coreCard.recipient = record.object(forKey: "CD_recipient") as! String
            coreCard.sender = record.object(forKey: "CD_sender") as? String
            coreCard.an1 = record.object(forKey: "CD_an1") as! String
            coreCard.an2 = record.object(forKey: "CD_an2") as! String
            coreCard.an2URL = record.object(forKey: "CD_an2URL") as! String
            coreCard.an3 = record.object(forKey: "CD_an3") as! String
            coreCard.an4 = record.object(forKey: "CD_an4") as! String
            coreCard.date = record.object(forKey: "CD_date") as! Date
            coreCard.font = record.object(forKey: "CD_font") as! String
            coreCard.message = record.object(forKey: "CD_message") as! String
            coreCard.songID = record.object(forKey: "CD_songID") as? String
            coreCard.spotID = record.object(forKey: "CD_spotID") as? String
            coreCard.songName = record.object(forKey: "CD_songName") as? String
            coreCard.spotName = record.object(forKey: "CD_spotName") as? String
            coreCard.songArtistName = record.object(forKey: "CD_songArtistName") as? String
            coreCard.spotArtistName = record.object(forKey: "CD_spotArtistName") as? String
            coreCard.songArtImageData = record.object(forKey: "CD_songArtImageData") as? Data
            coreCard.songPreviewURL = record.object(forKey: "CD_songPreviewURL") as? String
            coreCard.songDuration = record.object(forKey: "CD_songDuration") as? String
            coreCard.inclMusic = record.object(forKey: "CD_inclMusic") as! Bool
            coreCard.spotImageData = record.object(forKey: "CD_spotImageData") as? Data
            coreCard.spotSongDuration = record.object(forKey: "CD_spotSongDuration") as? String
            coreCard.spotPreviewURL = record.object(forKey: "CD_spotPreviewURL") as? String
            coreCard.songAlbumName = record.object(forKey: "CD_songAlbumName") as? String
            coreCard.spotAlbumArtist = record.object(forKey: "CD_spotAlbumArtist") as? String
            coreCard.appleAlbumArtist = record.object(forKey: "CD_appleAlbumArtist") as? String
            coreCard.creator = record.object(forKey: "CD_creator") as? String
            coreCard.songAddedUsing = record.object(forKey: "CD_songAddedUsing") as? String
            coreCard.cardName = record.object(forKey: "CD_cardName") as! String
            coreCard.cardName = record.object(forKey: "CD_cardName") as! String
            coreCard.cardType = record.object(forKey: "CD_cardType") as! String
            coreCard.appleSongURL = record.object(forKey: "CD_appleSongURL") as! String
            coreCard.spotSongURL = record.object(forKey: "CD_spotSongURL") as! String
            coreCard.uniqueName = record.object(forKey: "CD_uniqueName") as! String
            coreCard.salooUserID = record.object(forKey: "CD_salooUserID") as! String
            coreCard.coverSizeDetails = record.object(forKey: "CD_coverSizeDetails") as! String
            coreCard.unsplashImageURL = record.object(forKey: "CD_unsplashImageURL") as! String
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            if let asset = record["CD_collageAsset"] as? CKAsset {
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let collageData = try Data(contentsOf: asset.fileURL!)
                        DispatchQueue.main.async {
                            coreCard.collage = collageData
                            dispatchGroup.leave()
                        }
                    }
                    catch {
                        print("Failed to read data from CKAsset: \(error)")
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.enter()
            ImageLoader.shared.loadImage(from: coreCard.unsplashImageURL!) { data in
                DispatchQueue.main.async {
                    coreCard.coverImage = data
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { print("getRecord complete..."); completion(coreCard, record)}}
        }
    }
}

class AMAuthError: ObservableObject {
    static let shared = AMAuthError()
    @Published var errorMessage = String()
}


class ChosenSong: ObservableObject {
    static let shared = ChosenSong()
    @Published var id = String()
    @Published var name = String()
    @Published var artistName = String()
    @Published var artwork = Data()
    @Published var isPlaying = Bool()
    @Published var durationInSeconds = Double()
    @Published var songPreviewURL = String()
    @Published var songAlbumName = String()
    @Published var spotID = String()
    @Published var spotName = String()
    @Published var spotArtistName = String()
    @Published var spotImageData = Data()
    @Published var spotSongDuration = Double()
    @Published var spotPreviewURL = String()
    @Published var songAddedUsing = String()
    @Published var appleAlbumArtist = String()
    @Published var spotAlbumArtist = String()
    @Published var discNumber = Int()
    @Published var appleSongURL = String()
    @Published var spotSongURL = String()

}

class CloudRecord: ObservableObject {
    static let shared = CloudRecord()
    @Published var theRecord: CKRecord?
}

class ChosenCoverImageObject: ObservableObject {
    static let shared = ChosenCoverImageObject()
    @Published var coverSizeDetails = String()
    @Published var id = UUID()
    @Published var imageID = UUID()
    @Published var coverImage = Data()
    @Published var smallImageURLString = String()
    @Published var coverImagePhotographer = String()
    @Published var coverImageUserName = String()
    @Published var downloadLocation = String()
    @Published var index = Int()
    @Published var frontCoverIsPersonalPhoto = Int()
    @Published var pageCount = 1
    //func hash(into hasher: inout Hasher) {
    //    hasher.combine(downloadLocation)
    //}
}

class NoteField: ObservableObject  {
    static let shared = NoteField()
    @Published var noteText = MaximumText(limit: 225, value:  "Write Your Message Here")
    @Published var recipient = MaximumText(limit: 20, value: "To:")
    @Published var sender = MaximumText(limit: 20, value: "From:")
    @Published var cardName = MaximumText(limit: 20, value: "Name Your Card")
    @Published var font = "Papyrus"
    @Published var willHandWrite = Bool()
    @Published var eCardText = String()
    @Published var printCardText = String()
}

class CardProgress: ObservableObject {
    static let shared = CardProgress()
    @Published var currentStep = 1
    @Published var maxStep = 1
}


class MaximumText: ObservableObject {
    // variable for character limit
    private let limit: Int
    init(limit: Int, value: String) {
        self.limit = limit
        self.value = value
    }
    
    // value that text field displays
    @Published var value: String {
        didSet {
            if value.count > self.limit {
                value = String(value.prefix(self.limit))
                self.hasReachedLimit = true
            } else {
                self.hasReachedLimit = false
            }
        }
    }
    
    @Published var hasReachedLimit = false
}

struct CoverImageObject: Identifiable, Hashable {
    let id = UUID()
    let coverImage: Data?
    let smallImageURL: URL
    let coverImagePhotographer: String
    let coverImageUserName: String
    let downloadLocation: String
    let index: Int
    func hash(into hasher: inout Hasher) {
        hasher.combine(downloadLocation)
    }
}

class Annotation: ObservableObject {
    static let shared = Annotation()
    @Published var text1 = String()
    @Published var text2 = String()
    @Published var text2URL = URL(string: "https://salooapp.com")!
    @Published var text3 = String()
    @Published var text4 = String()
}

//class CollageImage: ObservableObject {@Published var collageImage = UIImage()}

class CollageImage: ObservableObject {
    static let shared = CollageImage()
    @Published var chosenStyle = Int()
    @Published var collageImage = Data()
    @Published var image1 = Data()
    @Published var image2 = Data()
    @Published var image3 = Data()
    @Published var image4 = Data()

}


class AddMusic: ObservableObject {
    static let shared = AddMusic()
    @Published var addMusic: Bool = false
    
}




public class ChosenImages: ObservableObject {
    static let shared = ChosenImages()
    @Published var imagePlaceHolder: Image?
    @Published var chosenImageA: UIImage?
    @Published var chosenImageB: UIImage?
    @Published var chosenImageC: UIImage?
    @Published var chosenImageD: UIImage?
}

class InOut: ObservableObject {
    enum SendReceive {
        case inbox
        case outbox
        case draftbox
    }
}

class MusicSubscription: ObservableObject {
    static let shared = MusicSubscription()
    @Published var timeToAddMusic = false
    @Published var type: MusicSubscriptionOptions = .Neither
}

enum MusicSubscriptionOptions {
    case Apple
    case Spotify
    case Neither
}

class UserSession: ObservableObject {
    static let shared = UserSession()
    @Published var isSignedIn: Bool = UserDefaults.standard.string(forKey: "SalooUserID") != nil
    @Published var salooID = String()
    func updateLoginStatus() {
        isSignedIn = UserDefaults.standard.string(forKey: "SalooUserID") != nil
    }
}


class UnmanagedPlaceHolder: NSObject {}

class ChosenCollageStyle: ObservableObject {@Published var chosenStyle: Int?}
class SpotifyAuth: ObservableObject {
    @Published var authForRedirect = String()
    @Published var auth_code = String()
    //@Published var returnedRedirectURI = String()
    @Published var access_Token = String()
    @Published var refresh_Token = String()
    @Published var deviceID = String()
    @Published var playingSong = Bool()
    @Published var userID = String()
    @Published var salooPlaylistID = String()
    @Published var songID = String()
    @Published var snapShotID = String()
}

class AlertVars: ObservableObject {
    static let shared = AlertVars()
    @Published var activateAlert: Bool = false
    @Published var alertType: ActiveAlert = .signInFailure
    private init() {}
    
    var activateAlertBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.activateAlert },
            set: { self.activateAlert = $0 }
        )
    }
    
    
}


class CollageBlocksAndViews {

    func blockForStyle() -> some View {return GeometryReader {geometry in HStack(spacing: 0) {Rectangle().fill(Color.gray).border(Color.black)}}}
    func onePhotoView(block: some View) -> some View {return block}
    func twoPhotoWide(block: some View) -> some View {return VStack(spacing:0){block; block}}
    func twoPhotoLong(block: some View) -> some View {return HStack(spacing:0){block; block}}
    func twoShortOneLong(block: some View) -> some View {return HStack(spacing:0){VStack(spacing:0){block; block}; block}}
    func twoNarrowOneWide(block: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){block; block}; block}}
    func fourPhoto(block: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){block; block}; HStack(spacing:0){block; block}}}
    
}

enum ActiveSheet: Identifiable, Equatable {
    #if os(iOS)
    case photoPicker // Unavailable in watchOS.
    #elseif os(watchOS)
    case photoContextMenu(CoreCard) // .contextMenu is deprecated in watchOS, so use action list instead.
    #endif
    case cloudSharingSheet(CKShare)
    case sharePicker(CoreCard)
    case taggingView(CoreCard)
    case ratingView(CoreCard)
    case participantView(CKShare)
    /**
     Use the enumeration member name string as the identifier for Identifiable.
     In the case where an enumeration has an associated value, use the label, which is equal to the member name string.
     */
    var id: String {
        let mirror = Mirror(reflecting: self)
        if let label = mirror.children.first?.label {
            return label
        } else {
            return "\(self)"
        }
    }
    
    
    

}


enum eCardType {
    case musicAndGift
    case musicNoGift
    case giftNoMusic
    case noMusicNoGift
}


class CardPrep: ObservableObject {
    static let shared = CardPrep()
    var chosenSong =  ChosenSong()
    var cardType = String()
}


class ImageLoader: ObservableObject {
    static let shared = ImageLoader()
    @Published var image: UIImage?
    
    func loadImage(from urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string.")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print("Data Task Error: \(error)")
                completion(nil)
                return
            }
            
            completion(data)
        }
        task.resume()
    }
}


class UCVImageObjectModel: ObservableObject {
    @Published var imageObjects: [CoverImageObject] = []
    
    func getPhotosFromCollection(collectionID: String, page_num: Int) {
        PhotoAPI.getPhotosFromCollection(collectionID: collectionID, page_num: page_num, completionHandler: { (response, error) in
            print(".....")
            print(collectionID)
            print(page_num)
            print(response)
            if response != nil {
                DispatchQueue.main.async {
                    for picture in response! {
                        if picture.urls.small != nil && picture.user.username != nil && picture.user.name != nil && picture.links.download_location != nil {
                            let thisPicture = picture.urls.small
                            let imageURL = URL(string: thisPicture!)
                            let newObj = CoverImageObject.init(coverImage: nil, smallImageURL: imageURL!, coverImagePhotographer: picture.user.name!, coverImageUserName: picture.user.username!, downloadLocation: picture.links.download_location!, index: self.imageObjects.count)
                            self.imageObjects.append(newObj)
                    }}
                }
            }
            if response != nil {print("No Response!"); self.imageObjects = []}
            else {debugPrint(error?.localizedDescription ?? "Error Getting Photos from Collection")}
        })
    }
}



class APIManager: ObservableObject {
    static let shared = APIManager()
    let baseURL = "https://getSalooKeys.azurewebsites.net/getkey"
    @Published var unsplashAPIKey = String()
    var unsplashSecretKey = String()
    var spotSecretKey = String()
    var spotClientIdentifier = String()
    var appleMusicDevToken = String()
    var keys: [String: String] = [:]
    //guard let url = URL(string: "https://saloouserstatus.azurewebsites.net/is_banned?user_id=\(userId)")
    //@Published var spotifyManager: SpotifyManager?



    init() {
        DispatchQueue.global(qos: .background).async {
            self.getSecret(keyName: "unsplashAPIKey", forceGetFromAzure: nil) { keyval in
                DispatchQueue.main.async {
                    self.unsplashAPIKey = keyval ?? ""
                    CollectionManager.shared.createOccassionsFromUserCollections()
                }
            }
        }
    }
    
    func generateNewAMDevToken(completion: @escaping () -> Void) {
        
    }
    
    
    
    
    
    func initializeAM(completion: @escaping () -> Void) {
        self.getSecret(keyName: "appleMusicDevToken", forceGetFromAzure: false) { keyval in
            print("GOT SECRET \(keyval)")
            if keyval != nil {
                DispatchQueue.main.async {self.appleMusicDevToken = keyval ?? ""; completion()}
            }
            else {self.getSecret(keyName: "appleMusicDevToken", forceGetFromAzure: true) { keyval2 in
                DispatchQueue.main.async {self.appleMusicDevToken = keyval ?? ""; completion()}
            }
            }
        }
    }
    

    
    func initializeSpotifyManager(completion: @escaping () -> Void) {
        // Here, you're getting the keys for Spotify API
        DispatchQueue.global(qos: .background).async {
            self.getSecret(keyName: "spotClientIdentifier", forceGetFromAzure: false) { keyval in
                DispatchQueue.main.async {
                self.spotClientIdentifier = keyval!
                    self.getSecret(keyName: "spotSecretKey", forceGetFromAzure: false){keyval in print("spotSecretKey is \(String(describing: keyval))")
                        self.spotSecretKey = keyval!
                        SpotifyManager.shared.initializeConfiguration()
                        completion()
                    }
                }
            }
        }
    }

    func getSecret(keyName: String, forceGetFromAzure: Bool?, completion: @escaping (String?) -> Void) {
        let fullURL = baseURL + "?keyName=\(keyName)"
        print(fullURL)
        guard let url = URL(string: fullURL) else {fatalError("Invalid URL")}
        
        if forceGetFromAzure == false {
            if let storedKey = loadFromKeychain(key: keyName) {
                completion(storedKey)
                return
            }
            self.fetchSecretFromURL(url: url, completion: { value in
                if let value = value {
                    self.saveToKeychain(key: keyName, value: value)
                    completion(value)
                }
                else {completion(nil)}
            })
        }
        else {
            self.fetchSecretFromURL(url: url, completion: { value in
                if let value = value {
                    self.saveToKeychain(key: keyName, value: value)
                    completion(value)
                }
                else {completion(nil)}
            })
        }
    }

    func fetchSecretFromURL(url: URL, completion: @escaping (String?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
            } else if let data = data {
                let jsonData = String(data: data, encoding: .utf8)
                if let jsonData = jsonData {
                    let data: Data? = Data(jsonData.utf8)
                    do {
                        let json = try JSONDecoder().decode([String: String].self, from: data!)
                        if let value = json["value"] {
                            completion(value)
                        }
                    } catch {
                        print("error:\(error)")
                    }
                }
            }
        }

        task.resume()
    }

    
    
    
    func saveToKeychain(key: String, value: String) {
        let keyData = key.data(using: .utf8)!
        let valueData = value.data(using: .utf8)!
        
        // First delete any existing items with the same key
        let deleteQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                          kSecAttrAccount as String: keyData]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Then add the new item
        let addQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: keyData,
                                       kSecValueData as String: valueData]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Failed to save data to Keychain")
            return
        }
    }


    func loadFromKeychain(key: String) -> String? {
        let keyData = key.data(using: .utf8)!
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: keyData,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            print("Failed to load data from Keychain")
            return nil
        }
        
        let valueData = item as! Data
        print("Got Key \(String(data: valueData, encoding: .utf8)) for \(key)")
        return String(data: valueData, encoding: .utf8)
    }
}

class CollectionManager: ObservableObject {
    static let shared = CollectionManager()
    @Published var collections: [CollectionPair2] = []
    private var timer: Timer?
    
    let titleToType = [
        "Birthday 🎈": CollectionType.yearRound,
        "Postcard ✈️": CollectionType.yearRound,
        "Wedding and Anniversary 💒": CollectionType.yearRound,
        "Graduation 🎓": CollectionType.yearRound,
        "Christmas 🎄": CollectionType.winter,
        "Hanukkah 🕎": CollectionType.winter,
        "New Years Eve 🎆": CollectionType.winter,
        "Mother's Day 🌸": CollectionType.spring,
        "4th of July 🇺🇸": CollectionType.summer,
        "Father's Day 🍻": CollectionType.summer,
        "Thanksgiving 🍁": CollectionType.fall,
        "Rosh Hashanah 🔯": CollectionType.fall,
        "Juneteenth ✊🏿" : CollectionType.summer,
        "Pride 🏳️‍🌈": CollectionType.summer,
        "Easter 🐇": CollectionType.spring,
        "Mardi Gras 🎭": CollectionType.winter,
        "Eid al-Fitr ☪️": CollectionType.spring,
        "St. Patrick's Day 🍀": CollectionType.spring,
        "Cinco De Mayo 🇲🇽": CollectionType.spring,
        "Halloween 🎃": CollectionType.fall,
        "Lunar New Year 🐉": CollectionType.winter,
        "Valentine’s Day ❤️": CollectionType.winter,
        "Baby Shower 🐣": CollectionType.yearRound

    ]

    
    func createOccassionsFromUserCollections() {
        PhotoAPI.getUserCollections(username: "samuelblack11", completionHandler: { (response, error) in
            if response != nil {
                var allCollections = [CollectionPair2]()

                for collection in response! {
                    if self.titleToType.contains(where: { $0.key == collection.title }) {
                        // Look up the type, defaulting to yearRound if not found
                        let type = self.titleToType[collection.title] ?? .yearRound
                        let collectionPair = CollectionPair2(title: collection.title, id: collection.id, type: type.rawValue)
                        allCollections.append(collectionPair)
                    }
                }

                DispatchQueue.main.async {
                    self.collections = allCollections
                }
            } else if error != nil {
                print("No Response!")
                debugPrint(error?.localizedDescription)
            }
        })
    }



}


class LinkURL: ObservableObject {
    static let shared = LinkURL()
    @Published var linkURL = String()
}

class SpotifyManager: ObservableObject {
    static let shared = SpotifyManager()
    var config: SPTConfiguration?
    var auth_code = String()
    var refresh_token = String()
    var access_token = String()
    var accessType = String()
    var accessExpiresAt = Date()
    var authForRedirect = String()
    var songID = String()
    var appRemote: SPTAppRemote? = nil
    let spotPlayerDelegate = SpotPlayerViewDelegate()
    let defaults = UserDefaults.standard
    @State private var invalidAuthCode = false
    @Published var showWebView = false
    @State private var tokenCounter = 0
    @State var refreshAccessToken = false
    var noInternet: (() -> Void)?
    @Published var gotToAppInAppStore = Bool()
    @Published var appRemoteDisconnected = 0
    @Published var isSpotPlayerViewShowing: Bool = false
    @Published var currentTrackId = String()
    @Published var resetPlayerToStart = Bool()
    init() {
        enum UserDefaultsError: Error {case noMusicSubType}
        do {
            guard let musicSubType = UserDefaults.standard.object(forKey: "MusicSubType") as? String, musicSubType == "Spotify" else {
                throw UserDefaultsError.noMusicSubType
            }
        } catch {print("Caught error: \(error)")}
    }

    func initializeConfiguration() {
        let spotClientIdentifier = APIManager.shared.spotClientIdentifier
        if spotClientIdentifier.isEmpty {
            print("Error: Spotify client identifier is not available")
            return
        }
        config = SPTConfiguration(clientID: spotClientIdentifier, redirectURL: URL(string: "saloo://")!)
        if appRemote == nil {instantiateAppRemote()} else if appRemote?.isConnected == false {appRemote?.connect()}
        auth_code = defaults.object(forKey: "SpotifyAuthCode") as? String ?? ""
        refresh_token = defaults.object(forKey: "SpotifyRefreshToken") as? String ?? ""
        access_token = defaults.object(forKey: "SpotifyAccessToken") as? String ?? ""
        accessExpiresAt = defaults.object(forKey: "SpotifyAccessTokenExpirationDate") as? Date ?? Date.distantPast
        updateCredentialsIfNeeded{success in }
    }
    
    func hasTokenExpired() -> Bool {
        if let expirationDate = defaults.object(forKey: "SpotifyAccessTokenExpirationDate") as? Date {
            return Date() > expirationDate}
        else {return true}
    }
    
    func verifySubType(completion: @escaping (Bool) -> Void){
        SpotifyAPI.shared.getCurrentUserProfile(accessToken: self.access_token) { (profile, error) in
            print("----")
            if let subType = profile?.product {self.accessType = subType}
            if self.accessType != "premium" {completion(false)}
            else{completion(true)}
        }
    }
    
    func updateCredentialsIfNeeded(completion: @escaping (Bool) -> Void) {

        if NetworkMonitor.shared.isConnected {
            if auth_code.isEmpty || auth_code == "AuthFailed" {
                print("auth_code is empty")
                requestSpotAuth {response in
                    self.authForRedirect = response!
                    self.showWebView = true
                    self.refreshAccessToken = true
                }
            }
            else if hasTokenExpired() {
                print("Token Expired...")
                refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
                self.getSpotTokenViaRefresh{success in }
                completion(true)
            }
            else {
                print("no new token needed...")
                completion(true)
            }
        } else {
            print("Else called in udpateSpotCredentials...")
            self.noInternet?()
            completion(false)
        }
    }

    func getSpotToken(completion: @escaping (Bool) -> Void) {
        print("getSpotToken called")
        SpotifyAPI.shared.getToken(authCode: auth_code) { (response, error) in
            let success = self.processTokenRequest(response: response, error: error)
            self.instantiateAppRemote()
            completion(success)
        }
    }

    func getSpotTokenViaRefresh(completion: @escaping (Bool) -> Void) {
        print("getSpotTokenViaRefresh called")
        SpotifyAPI.shared.getTokenViaRefresh(refresh_token: refresh_token) { (response, error) in
            let success = self.processTokenRequest(response: response, error: error)
            self.instantiateAppRemote()
            completion(success)
        }
    }

    func processTokenRequest(response: SpotTokenResponse?, error: Error?) -> Bool {
        if let response = response {
            updateTokenData(with: response)
            return true // Indicate success.
        }
        if let error = error {
            print("Error... \(error.localizedDescription)!")
            self.invalidAuthCode = true
            self.auth_code = ""
            return false // Indicate failure.
        }
        return false // Indicate failure if no response and no error (should not happen in practice).
    }


    func updateTokenData(with response: SpotTokenResponse) {
        let expirationDate = Date().addingTimeInterval(response.expires_in)
        self.access_token = response.access_token
        if let refreshToken = response.refresh_token {self.refresh_token = refreshToken}
        self.accessExpiresAt = expirationDate
        self.appRemote?.connectionParameters.accessToken = self.access_token
        self.defaults.set(response.access_token, forKey: "SpotifyAccessToken")
        self.defaults.set(expirationDate, forKey: "SpotifyAccessTokenExpirationDate")
        self.defaults.set(self.refresh_token, forKey: "SpotifyRefreshToken")
    }

    func requestSpotAuth(completion: @escaping (String?) -> Void) {
        print("called....requestSpotAuth")
        invalidAuthCode = false
        SpotifyAPI.shared.requestAuth(completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    if response!.contains("https://salooapp.com/?code="){}
                    else{self.authForRedirect = response!; self.showWebView = true}
                    self.refreshAccessToken = true
                    completion(response)
                }
            }
            else{completion(nil)}
        })
        
    }

    
    func instantiateAppRemote() {
        self.appRemote = SPTAppRemote(configuration: self.config!, logLevel: .debug)
        if (UserDefaults.standard.object(forKey: "SpotifyAccessToken") as? String) != nil {
            self.appRemote?.connectionParameters.accessToken = (UserDefaults.standard.object(forKey: "SpotifyAccessToken") as? String)!
            self.appRemote?.delegate = self.spotPlayerDelegate
            appRemote?.connect()
            print("instantiated app remote...")
        }
    }
    
    func connect() {appRemote?.connect()}
    func disconnect() {appRemote?.disconnect()}
    var defaultCallback: SPTAppRemoteCallback? {
        get {
            return {[self] _, error in
                print("defaultCallBack Running...")
                if let error = error {print(error.localizedDescription)}
            }
        }
    }
    
}

class SpotPlayerViewDelegate: NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate  {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Connected appRemote")
        if let playerAPI = SpotifyManager.shared.appRemote?.playerAPI {
            print("Check1")
            playerAPI.delegate = SpotifyManager.shared.spotPlayerDelegate
            print("Check2")
            playerAPI.subscribe { (result, error) in
                print("subscribteResult")
                print(result)
                if let error = error {print("Error subscribing to player state changes: \(error)")}
        }
    }
        
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        SpotifyManager.shared.appRemoteDisconnected += 1
        print("Disconnected appRemote")
        
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Failed to connect appRemote")
        if let error = error {print("Error: \(error)")}
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        var salooURI = "spotify:track:\(SpotifyManager.shared.currentTrackId)"
        print("Called playerStateDidChange")
        print(salooURI)
        print(playerState.track.uri)
        if salooURI != playerState.track.uri {
            print("Track changed to: \(playerState.track.name) by \(playerState.track.artist.name)")
            SpotifyManager.shared.appRemote?.disconnect()
            SpotifyManager.shared.resetPlayerToStart = true
        }
    }
}


import Foundation

class RateLimiter {
    private let maxExecutionsPerSecond: Int
    private var executionQueue: DispatchQueue
    private var executionTimestamps: [Double] = []
    
    init(maxExecutionsPerSecond: Int) {
        self.maxExecutionsPerSecond = maxExecutionsPerSecond
        self.executionQueue = DispatchQueue(label: "com.Saloo.app", attributes: .concurrent)
    }
    
    func executeFunction(function: @escaping () -> Void) {
        let currentTimestamp = Date().timeIntervalSince1970
        var delay: Double = 0.0
        print("called executeFunction")
        executionQueue.sync {
            // Remove timestamps older than 1 second
            executionTimestamps = executionTimestamps.filter { currentTimestamp - $0 < 1 }
            
            // Calculate the number of executions made in the last second
            let executionsInLastSecond = executionTimestamps.count
            
            if executionsInLastSecond >= maxExecutionsPerSecond {
                // Delay the execution to comply with the rate limit
                delay = 1.0 - (currentTimestamp - executionTimestamps.first!)
            }
            
            // Add the current timestamp to the execution timestamps
            executionTimestamps.append(currentTimestamp)
        }
        
        if delay > 0 {
            // Delay the execution
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                print("Delayed exe")
                function()
            }
        } else {
            // Execute the function immediately
            print("Immediate exe")
            function()
        }
    }
}



struct CodableCoreCard: Codable, Identifiable {
    var id: String
    var cardName: String
    var occassion: String
    var recipient: String
    var sender: String?
    var an1: String
    var an2: String
    var an2URL: String
    var an3: String
    var an4: String
    var collage: Data?
    var coverImage: Data?
    var date: Date
    var font: String
    var message: String
    var uniqueName: String
    var songID: String?
    var spotID: String?
    var spotName: String?
    var spotArtistName: String?
    var songName: String?
    var songArtistName: String?
    var songArtImageData: Data?
    var songPreviewURL: String?
    var songDuration: String?
    var inclMusic: Bool
    var spotImageData: Data?
    var spotSongDuration: String?
    var spotPreviewURL: String?
    var creator: String?
    var songAddedUsing: String?
    var collage1: Data?
    var collage2: Data?
    var collage3: Data?
    var collage4: Data?
    var cardType: String?
    var recordID: String?
    var songAlbumName: String?
    var appleAlbumArtist: String?
    var spotAlbumArtist: String?
    var salooUserID: String?
    var sharedRecordID: String?
    var appleSongURL: String?
    var spotSongURL: String?
}

class ErrorMessageViewModel: ObservableObject {
    static let shared = ErrorMessageViewModel()
    @Published var errorMessage: String = ""
}


struct MessageComposerView: UIViewControllerRepresentable {
    
    let linkURL: URL
    let fromFinalize: Bool
    //let coverImage: Data
    func makeUIViewController(context: UIViewControllerRepresentableContext<MessageComposerView>) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        
        if MFMessageComposeViewController.canSendText() {
            // Modify this with the appropriate deepLinkURL and image
            let deepLinkURL = linkURL
            controller.body = deepLinkURL.absoluteString
            //controller.addAttachmentData(coverImage, typeIdentifier: "public.data", filename: "image.jpg")
        }
        
        controller.messageComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: UIViewControllerRepresentableContext<MessageComposerView>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageComposerView

        init(_ messageComposer: MessageComposerView) {
            self.parent = messageComposer
        }

        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true)
            if parent.fromFinalize == true {
                AlertVars.shared.alertType = .showCardComplete
                AlertVars.shared.activateAlert = true
            }
        }
    }
}
