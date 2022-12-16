//
//  Card+CoreDataProperties.swift
//  
//
//  Created by Sam Black on 8/1/22.
//
//

import Foundation
import CoreData
import SwiftUI
import CloudKit

struct Card: Identifiable {
    let id: String
    let cardName: String?
    let occassion: String?
    let recipient: String?
    let associatedRecord: CKRecord?
    let an1: String?
    let an2: String?
    let an2URL: String?
    let an3: String?
    let an4: String?
    let collage: Data?
    let coverImage: Data?
    let date: Date?
    let font: String?
    let message: String?

    
}

extension Card {
    
    init?(record: CKRecord) {
        guard let cardName = record["CD_cardName"] as? String,
            let occassion = record["CD_occassion"] as? String,
            let recipient = record["CD_recipient"] as? String,
            let an1 = record["CD_an1"] as? String,
            let an2 = record["CD_an2"] as? String,
            let an2URL = record["CD_an2URL"] as? String,
            let an3 = record["CD_an3"] as? String,
            let an4 = record["CD_an4"] as? String,
            let collage = record["CD_collage"] as? Data,
            let coverImage = record["CD_coverImage"] as? Data,
            let date = record["CD_date"] as? Date,
            let font = record["CD_font"] as? String,
            let message = record["CD_message"] as? String else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.cardName = cardName
        self.occassion = occassion
        self.recipient = recipient
        self.associatedRecord = record
        self.an1 = an1
        self.an2 = an2
        self.an2URL = an2URL
        self.an3 = an3
        self.an4 = an4
        self.collage = collage
        self.coverImage = coverImage
        self.date = date
        self.font = font
        self.message = message
    }

}
