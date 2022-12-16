//
//  CKModel.swift
//  GreetMe-2
//
//  Created by Sam Black on 12/15/22.
//

import Foundation
import Foundation
import SwiftUI
import CoreData
import CloudKit
import OSLog

@MainActor
final class CKModel: ObservableObject {
    
    enum ViewModelError: Error {
        case invalidShare
    }
    
    enum State {
        case loading
        case loaded(private: [Card], shared: [Card])
        case error(Error)
    }
    
    /// State directly observable by our view.
    @Published private(set) var state: State = .loading
    /// Use the specified iCloud container ID, which should also be present in the entitlements file.
    lazy var container = CKContainer(identifier: "iCloud.GreetMe_2")
    /// This project uses the user's private database.
    private lazy var pdb = container.privateCloudDatabase
    /// Sharing requires using a custom record zone.
    let recordZone = CKRecordZone(zoneName: "Cards")
    
    nonisolated init() {}
    
    // Initializes explicit state
    init(state: State) {
        self.state = state
    }
    
    //Prepares container by creating custom zone if needed
    func initialize() async throws {
        do {
            try await createZoneIfNeeded()
        } catch {
            state = .error(error)
        }
    }
    
    /// Fetches contacts from the remote databases and updates local state.
    func refresh() async throws {
        state = .loading
        do {
            let (privateCards, sharedCards) = try await fetchPrivateAndSharedCards()
            state = .loaded(private: privateCards, shared: sharedCards)
        } catch {
            state = .error(error)
        }
    }
    
    /// Fetches both private and shared contacts in parallel.
    /// - Returns: A tuple containing separated private and shared contacts.
    func fetchPrivateAndSharedCards() async throws -> (private: [Card], shared: [Card]) {
        // This will run each of these operations in parallel.
        async let privateCards = fetchCards(scope: .private, in: [recordZone])
        async let sharedCards = fetchSharedCards()
        print("**")
        try await print(privateCards)
        return (private: try await privateCards, shared: try await sharedCards)
    }
    
    /// Adds a new Card  to the database.
    func addCard(noteField: NoteField, searchObject: SearchParameter, an1: String, an2: String, an2URL: String, an3: String, an4: String, chosenObject: CoverImageObject, collageImage: CollageImage) async throws {
        
        let id = CKRecord.ID(zoneID: recordZone.zoneID)
        let cardRecord = CKRecord(recordType: "Card", recordID: id)
        cardRecord["cardName"] = noteField.cardName as CKRecordValue
        cardRecord["occassion"] = searchObject.searchText as? CKRecordValue
        cardRecord["recipient"] = noteField.recipient as CKRecordValue
        cardRecord["an1"] = an1 as CKRecordValue
        cardRecord["an2"] = an2 as CKRecordValue
        cardRecord["an2URL"] = an2URL as CKRecordValue
        cardRecord["an3"] = an3 as CKRecordValue
        cardRecord["an4"] = an4 as CKRecordValue
        cardRecord["font"] = noteField.font as CKRecordValue
        cardRecord["date"] = Date.now as CKRecordValue
        cardRecord["message"] = noteField.noteText as CKRecordValue
        //cardRecord["coverImage"] = chosenObject.coverImage! as CKRecordValue
        //cardRecord["collage"] = collageImage.collageImage.pngData() as CKRecordValue

        let coverURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(noteField.cardName).png")
        let collageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(noteField.cardName).png")
        do {
            try chosenObject.coverImage?.write(to: coverURL)
            try collageImage.collageImage.pngData()!.write(to: collageURL)
        }
        catch {
            print(error.localizedDescription)
        }
        
        let coverAsset = CKAsset(fileURL: coverURL)
        let collageAsset = CKAsset(fileURL: collageURL)
        cardRecord["coverImage"] = coverAsset
        cardRecord["collage"] = collageAsset

        do {
            try await pdb.save(cardRecord)
        } catch {
            debugPrint("ERROR: Failed to save new Card: \(error)")
            throw error
        }
    }
    
    /// Fetches an existing `CKShare` on a Contact record, or creates a new one in preparation to share a Contact with another user.
       /// - Parameters:
       ///   - contact: Contact to share.
       ///   - completionHandler: Handler to process a `success` or `failure` result.
       func fetchOrCreateShare(card: Card) async throws -> (CKShare, CKContainer) {
           guard let existingShare = card.associatedRecord.share else {
               let share = CKShare(rootRecord: card.associatedRecord)
               share[CKShare.SystemFieldKey.title] = "Card: \(card.cardName)"
               _ = try await pdb.modifyRecords(saving: [card.associatedRecord, share], deleting: [])
               return (share, container)
           }

           guard let share = try await pdb.record(for: existingShare.recordID) as? CKShare else {
               throw ViewModelError.invalidShare
           }

           return (share, container)
       }

       // MARK: - Private
       /// Fetches contacts for a given set of zones in a given database scope.
       /// - Parameters:
       ///   - scope: Database scope to fetch from.
       ///   - zones: Record zones to fetch contacts from.
       /// - Returns: Combined set of contacts across all given zones.
       private func fetchCards(
           scope: CKDatabase.Scope,
           in zones: [CKRecordZone]
       ) async throws -> [Card] {
           let database = container.database(with: scope)
           var allCards: [Card] = []

           // Inner function retrieving and converting all Card records for a single zone.
           @Sendable func cardsInZone(_ zone: CKRecordZone) async throws -> [Card] {
               var allCards: [Card] = []

               /// `recordZoneChanges` can return multiple consecutive changesets before completing, so
               /// we use a loop to process multiple results if needed, indicated by the `moreComing` flag.
               var awaitingChanges = true
               /// After each loop, if more changes are coming, they are retrieved by using the `changeToken` property.
               var nextChangeToken: CKServerChangeToken? = nil

               while awaitingChanges {
                   let zoneChanges = try await database.recordZoneChanges(inZoneWith: zone.zoneID, since: nextChangeToken)
                   print("&&")
                   //let cards = zoneChanges.modificationResultsByID.values
                   //    .compactMap { try? $0.get().record }
                   //    .compactMap { Card(record: $0) }
                   //print("**")
                   //print(cards)
                   //print("--")
                   //allCards.append(contentsOf: cards)
                  for rec in zoneChanges.modificationResultsByID.values {
                      var c: CKRecord
                      try c = rec.get().record
                      print("the record.....")
                      print(c)
                      let c2 = Card(record: c)
                      print("000")
                      print(c2)
                      allCards.append(c2!)
                   }
                   print("!!")
                   print(allCards)
                   awaitingChanges = zoneChanges.moreComing
                   nextChangeToken = zoneChanges.changeToken
               }

               return allCards
           }

           // Using this task group, fetch each zone's contacts in parallel.
           try await withThrowingTaskGroup(of: [Card].self) { group in
               for zone in zones {
                   group.addTask {
                       try await cardsInZone(zone)
                   }
               }
               // As each result comes back, append it to a combined array to finally return.
               for try await contactsResult in group {
                   allCards.append(contentsOf: contactsResult)
               }
           }
           return allCards
       }

       /// Fetches all shared Contacts from all available record zones.
       private func fetchSharedCards() async throws -> [Card] {
           let sharedZones = try await container.sharedCloudDatabase.allRecordZones()
           guard !sharedZones.isEmpty else {
               return []
           }

           return try await fetchCards(scope: .shared, in: sharedZones)
       }

       /// Creates the custom zone in use if needed.
       private func createZoneIfNeeded() async throws {
           // Avoid the operation if this has already been done.
           guard !UserDefaults.standard.bool(forKey: "isZoneCreated") else {
               return
           }

           do {
               _ = try await pdb.modifyRecordZones(saving: [recordZone], deleting: [])
           } catch {
               print("ERROR: Failed to create custom zone: \(error.localizedDescription)")
               throw error
           }

           UserDefaults.standard.setValue(true, forKey: "isZoneCreated")
       }
   }
