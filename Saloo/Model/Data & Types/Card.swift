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

public class CoreCard: NSManagedObject, Identifiable {
    
}

extension CoreCard {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<CoreCard> {
        return NSFetchRequest<CoreCard>(entityName: "CoreCard")
    }

    //@NSManaged public var id: String
    @NSManaged public var cardName: String
    @NSManaged public var occassion: String
    @NSManaged public var recipient: String
    @NSManaged public var sender: String?
    @NSManaged public var associatedRecord: CKRecord
    @NSManaged public var an1: String
    @NSManaged public var an2: String
    @NSManaged public var an2URL: String
    @NSManaged public var an3: String
    @NSManaged public var an4: String
    @NSManaged public var collage: Data?
    @NSManaged public var coverImage: Data?
    @NSManaged public var date: Date
    @NSManaged public var font: String
    @NSManaged public var message: String
    @NSManaged public var uniqueName: String
    @NSManaged public var songID: String?
    @NSManaged public var spotID: String?
    @NSManaged public var songName: String?
    @NSManaged public var songArtistName: String?
    @NSManaged public var songArtImageData: Data?
    @NSManaged public var songPreviewURL: String?
    @NSManaged public var songDuration: String?
    @NSManaged public var inclMusic: Bool
    @NSManaged public var spotImageData: Data?
    @NSManaged public var spotSongDuration: String?
    @NSManaged public var spotPreviewURL: String?


}

struct Card: Identifiable, Hashable {
    let id: String
    let cardName: String
    let occassion: String?
    let recipient: String?
    let sender: String?
    let associatedRecord: CKRecord
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
    let chosenSong: Data?
    let songID: String?
    let spotID: String?
    let songName: String?
    let songArtistName: String?
    let songArtImageData: Data?
    let songPreviewURL: String?
    let songDuration: String?
    let inclMusic: Bool?
    let spotImageData: Data?
    let spotSongDuration: String?
    let spotPreviewURL: String?

}

extension Card {
    
    init?(record: CKRecord) {
        guard let cardName = record["cardName"] as? String,
              let occassion = record["occassion"] as? String,
              let recipient = record["recipient"] as? String,
              let sender = record["sender"] as? String,
              let an1 = record["an1"] as? String,
              let an2 = record["an2"] as? String,
              let an2URL = record["an2URL"] as? String,
              let an3 = record["an3"] as? String,
              let an4 = record["an4"] as? String,
              let collage = record["collage"] as? Data,
              let coverImage = record["coverImage"] as? Data,
              let date = record["date"] as? Date,
              let font = record["font"] as? String,
              let message = record["message"] as? String,
              let chosenSong = record["chosenSong"] as? Data,
              let songID = record["songID"] as? String,
              let spotID = record["spotID"] as? String,
              let songName = record["songName"] as? String,
              let songArtistName = record["songArtistName"] as? String,
              let songArtImageData = record["songArtImageData"] as? Data,
              let songPreviewURL = record["songPreviewURL"] as? String,
              let songDuration = record["songDuration"] as? String,
              let inclMusic = record["inclMusic"] as? Bool,
              let spotImageData = record["spotImageData"] as? Data,
              let spotSongDuration = record["spotSongDuration"] as? String,
              let spotPreviewURL = record["spotPreviewURL"] as? String else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.cardName = cardName
        self.occassion = occassion
        self.recipient = recipient
        self.sender = sender
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
        self.chosenSong = chosenSong
        self.songID = songID
        self.spotID = spotID
        self.songName = songName
        self.songArtistName = songArtistName
        self.songArtImageData = songArtImageData
        self.songPreviewURL = songPreviewURL
        self.songDuration = songDuration
        self.inclMusic = inclMusic
        self.spotImageData = spotImageData
        self.spotSongDuration = spotSongDuration
        self.spotPreviewURL = spotPreviewURL


    }
}
