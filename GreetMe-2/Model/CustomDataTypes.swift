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

class ViewTransitions: ObservableObject {
    @Published var isShowingOccassions = true
    @Published var isShowingUCV = false
    @Published var isShowingConfirmFrontCover = false
    @Published var isShowingCollageMenu = false
    @Published var isShowingCalendar = false
    @Published var isShowingImagePicker = false
    @Published var isShowingWriteNote = false
    @Published var isShowingCameraCapture = false
    @Published var loadedImagefromLibraryOrCamera = false
    @Published var isShowingFinalize = false
    @Published var isShowingSentCards = false
    @Published var isShowingReceivedCards = false
    @Published var isShowingCollageOne = false
    @Published var isShowingCollageTwo = false
    @Published var isShowingCollageThree = false
    @Published var isShowingCollageFour = false
    @Published var isShowingCollageFive = false
    @Published var isShowingCollageSix = false

}

struct ChosenCollection {
    @State var occassion: String!
    @State var collectionID: String!
}

class Occassion: ObservableObject {
    @Published var occassion = String()
    @Published var collectionID = String()
}

public class ShowDetailView: ObservableObject {
    @Published public var showDetailView: Bool = false
}

class ChosenCoverImageObject: ObservableObject {
    @Published var id = UUID()
    @Published var coverImage = Data()
    @Published var smallImageURLString = String()
    @Published var coverImagePhotographer = String()
    @Published var coverImageUserName = String()
    @Published var downloadLocation = String()
    @Published var index = Int()
    //func hash(into hasher: inout Hasher) {
    //    hasher.combine(downloadLocation)
    //}
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

struct CollageImage {
    let collageImage: UIImage
}

struct NoteField {
    var noteText: String
    var recipient: String
    var cardName: String
    var font: String
}

class HandWrite: ObservableObject {
    @Published var willHandWrite: Bool = false
}
// https://programmingwithswift.com/swiftui-textfield-character-limit/
class TextLimiter: ObservableObject {
    // variable for character limit
    private let limit: Int
    
    init(limit: Int) {
        self.limit = limit
    }
    // value that text field displays
    @Published var value = "Write Your Note Here" {
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

