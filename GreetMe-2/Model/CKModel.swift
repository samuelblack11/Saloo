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
        //case loaded(private: [Card], shared: [Card])
        case loaded(myCards: [Card])
        case error(Error)
    }
    
    enum SendReceive {
        case inbox
        case outbox
    }
    
    /// State directly observable by our view.
    @Published private(set) var state: State = .loading
    @Published private(set) var whichBox: SendReceive = .inbox
    /// Use the specified iCloud container ID, which should also be present in the entitlements file.
    lazy var container = CKContainer(identifier: "iCloud.GreetMe_2")
    /// This project uses the user's private database.
    /// 
    private lazy var pdb = container.privateCloudDatabase

    /// Sharing requires using a custom record zone.
    let recordZone = CKRecordZone(zoneName: "Cards")
    let sharedZone = CKRecordZone(zoneName: "Cards")

    var myCards: [Card]!
    var cardsSharedWithMe: [Card]!

    
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
            //state = .loaded(private: privateCards, shared: sharedCards)
            if sharedCards != sharedCards {
                myCards = privateCards
            }
            else {
                myCards = privateCards + sharedCards
            }
            state = .loaded(myCards: myCards)
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
        //cardRecord["id"] = cardRecord.recordID.recordName as CKRecordValue
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
        cardRecord["coverImage"] = chosenObject.coverImage! as CKRecordValue
        cardRecord["collage"] = collageImage.collageImage.pngData()! as CKRecordValue

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
    
        func accept(_ metadata: CKShare.Metadata) async throws {
            try await self.container.accept(metadata)
        }
    

       // MARK: - Private
       /// Fetches contacts for a given set of zones in a given database scope.
       /// - Parameters:
       ///   - scope: Database scope to fetch from.
       ///   - zones: Record zones to fetch contacts from.
       /// - Returns: Combined set of contacts across all given zones.
       func fetchCards(
           scope: CKDatabase.Scope,
           in zones: [CKRecordZone]
       ) async throws -> [Card] {
           let database = container.database(with: scope)
           var myCards: [Card] = []

           // Inner function retrieving and converting all Card records for a single zone.
           @Sendable func cardsInZone(_ zone: CKRecordZone) async throws -> [Card] {
               var myCards: [Card] = []

               /// `recordZoneChanges` can return multiple consecutive changesets before completing, so
               /// we use a loop to process multiple results if needed, indicated by the `moreComing` flag.
               var awaitingChanges = true
               /// After each loop, if more changes are coming, they are retrieved by using the `changeToken` property.
               var nextChangeToken: CKServerChangeToken? = nil

               while awaitingChanges {
                   let zoneChanges = try await database.recordZoneChanges(inZoneWith: zone.zoneID, since: nextChangeToken)
                   print("&&")
                   let cards = zoneChanges.modificationResultsByID.values
                       .compactMap { try? $0.get().record }
                       .compactMap { Card(record: $0) }
                   myCards.append(contentsOf: cards)
                   awaitingChanges = zoneChanges.moreComing
                   nextChangeToken = zoneChanges.changeToken
               }

               return myCards
           }

           // Using this task group, fetch each zone's contacts in parallel.
           try await withThrowingTaskGroup(of: [Card].self) { group in
               for zone in zones {
                   group.addTask {
                       try await cardsInZone(zone)
                   }
               }
               // As each result comes back, append it to a combined array to finally return.
               for try await cardsResult in group {
                   myCards.append(contentsOf: cardsResult)
               }
           }
           return myCards
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
