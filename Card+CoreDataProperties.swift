//
//  Card+CoreDataProperties.swift
//  
//
//  Created by Sam Black on 8/1/22.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var an1: String?
    @NSManaged public var an2: String?
    @NSManaged public var an2URL: String?
    @NSManaged public var an3: String?
    @NSManaged public var an4: String?
    @NSManaged public var card: Data?
    @NSManaged public var cardName: String?
    @NSManaged public var collage: Data?
    @NSManaged public var coverImage: Data?
    @NSManaged public var date: Date?
    @NSManaged public var font: String?
    @NSManaged public var message: String?
    @NSManaged public var occassion: String?
    @NSManaged public var recipient: String?

}

extension Card : Identifiable {
    
    enum CardRecordKeys {
       static let type = "Card"
       static let card = "card"
       static let cardName = "cardName"
       static let collage = "collage"
       static let coverImage = "coverImage"
       static let date = "date"
       static let message = "message"
       static let occassion = "occassion"
       static let recipient = "recipient"
       static let font = "font"
       static let an1 = "an1"
       static let an2 = "an2"
       static let an2URL = "an2URL"
       static let an3 = "an3"
       static let an4 = "an4"
   }

    enum SharedZone {
       static let name = "SharedZone"
       static let ID = CKRecordZone.ID(
           zoneName: name,
           ownerName: CKCurrentUserDefaultName
       )
   }

}
