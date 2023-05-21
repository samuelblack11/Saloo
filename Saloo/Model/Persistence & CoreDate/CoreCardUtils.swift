//
//  CoreCardUtils.swift
//  Saloo
//
//  Created by Sam Black on 5/10/23.
//

import Foundation

struct CoreCardUtils {
    
    static func loadCoreCards() -> [CoreCard] {
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
    
    static func shareStatus(card: CoreCard) -> (Bool, Bool) {
        var isCardShared: Bool?
        var hasAnyShare: Bool?
        isCardShared = (PersistenceController.shared.existingShare(coreCard: card) != nil)
        hasAnyShare = PersistenceController.shared.shareTitles().isEmpty ? false : true
        
        return (isCardShared!, hasAnyShare!)
    }
}
