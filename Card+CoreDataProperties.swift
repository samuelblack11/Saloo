//
//  Card+CoreDataProperties.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/4/22.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var card: Data?
    @NSManaged public var collage: Data?
    @NSManaged public var coverImage: Data?
    @NSManaged public var date: Date?
    @NSManaged public var message: String?
    @NSManaged public var occassion: String?
    @NSManaged public var recipient: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var font: String?

}

extension Card : Identifiable {

}
