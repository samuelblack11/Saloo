//
//  ShowPriorCardsView.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import Foundation
import SwiftUI
import CloudKit
import CoreData

struct Outbox: View {
    @EnvironmentObject private var cm: CKModel
    //@State private var privateCards: [Card] = []
    //@State private var sharedCards: [Card]?
    @State private var privateCoreCards: [CoreCard] = []
    @State private var sharedCoreCards: [CoreCard]?
    // mycards = private + shared
    @State private var myCards: [Card]?
    
    var body: some View {
        NavigationView {
                //switch cm.state {
                //case .loading: VStack{EmptyView()}
                //case .error(let error):VStack {Text("An error occurred: \(error.localizedDescription)").padding(); Spacer()}
                //case let .loaded(sentCards: privateCards, receivedCards: privateCards):GridofCards(privateCards: $privateCards, receivedCards: privateCards)
                //}
                GridofCards(cardsForDisplay: loadCoreCards())
                //GridofCards(cardsForDisplay: filterCoreCards(coreCards: loadCoreCards(), whichBox: .outbox))
                //}
            
            
            
                
            }
            .onAppear {
                //deleteAllCoreCards()
                //Task {try await cm.initialize(); try await (privateCards, sharedCards) = cm.fetchPrivateAndSharedCards(); try await cm.refresh()}
        }
    }
}

extension Outbox {
    
    
    func filterCoreCards(coreCards: [CoreCard], whichBox: CKModel.SendReceive) -> [CoreCard] {
        var filteredCoreCards: [CoreCard] = []
        for coreCard in coreCards {
            print("----")
            print(coreCard.associatedRecord.creatorUserRecordID?.zoneID.ownerName)
            print("***")
            print(CKCurrentUserDefaultName)
            print("$$$")
            if whichBox == .outbox {
                if coreCard.associatedRecord.creatorUserRecordID?.zoneID.ownerName == CKCurrentUserDefaultName {
                    filteredCoreCards.append(coreCard)
                }
            }
            if whichBox == .inbox {
                if coreCard.associatedRecord.creatorUserRecordID?.zoneID.ownerName != CKCurrentUserDefaultName {
                    filteredCoreCards.append(coreCard)
                }
            }
        }
        return filteredCoreCards
    }
        
    
    
    
    func deleteAllCoreCards() {
        let request = CoreCard.createFetchRequest()
        var cardsFromCore: [CoreCard] = []
        do {
            cardsFromCore = try CoreDataStack.shared.context.fetch(request)
            for card in cardsFromCore {deleteCoreCard(coreCard: card)}
        }
        catch{}
    }
    func loadCoreCards() -> [CoreCard] {
        let request = CoreCard.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        var cardsFromCore: [CoreCard] = []
        do {
            cardsFromCore = try CoreDataStack.shared.context.fetch(request)
            print("Got \(cardsFromCore.count) Cards From Core")
            print("loadCoreDataEvents Called....")
            print(cardsFromCore)
        }
        catch {print("Fetch failed")}
        
        return cardsFromCore
    }
    
    func deleteCoreCard(coreCard: CoreCard) {
        do {CoreDataStack.shared.context.delete(coreCard);try CoreDataStack.shared.context.save()}
        catch {}
    }
    
}
