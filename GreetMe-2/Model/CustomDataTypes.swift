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
