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

struct ChosenCollection {@State var occassion: String!; @State var collectionID: String!}
class ChosenCoreCard: ObservableObject {@Published var chosenCard = CoreCard()}
class Occassion: ObservableObject {@Published var occassion = String(); @Published var collectionID = String()}
public class ShowDetailView: ObservableObject {@Published public var showDetailView: Bool = false}

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

class NoteField: ObservableObject  {
    @Published var noteText = String()
    @Published var recipient =  String()
    @Published var sender =  String()
    @Published var cardName = String()
    @Published var font = String()
    @Published var willHandWrite = Bool()
    @Published var eCardText = String()
    @Published var printCardText = String()
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

class CollageImage: ObservableObject {@Published var collageImage = UIImage()}
class HandWrite: ObservableObject { @Published var willHandWrite: Bool = false}

// https://programmingwithswift.com/swiftui-textfield-character-limit/
class TextLimiter: ObservableObject {
    // variable for character limit
    private let limit: Int
    init(limit: Int) {self.limit = limit}
    // value that text field displays
    @Published var value = "Write Your Note Here" {
        didSet {
            if value.count > self.limit {
                value = String(value.prefix(self.limit))
                self.hasReachedLimit = true
            } else {self.hasReachedLimit = false}
        }
    }
    @Published var hasReachedLimit = false
}




//struct ChosenImages: Equatable {
//    static func == (lhs: ChosenImages, rhs: ChosenImages) -> Bool {
//        return lhs.chosenImageA == rhs.chosenImageA && lhs.chosenImageB == rhs.chosenImageB && lhs.chosenImageC == rhs.chosenImageC && lhs.chosenImageD == rhs.chosenImageD
 //   }
 //   @State var chosenImageA: UIImage?
 //   @State var chosenImageB: UIImage?
 //   @State var chosenImageC: UIImage?
 //   @State var chosenImageD: UIImage?
//}


public class ChosenImages: ObservableObject {
    @Published var imagePlaceHolder: Image?
    @Published var chosenImageA: UIImage?
    @Published var chosenImageB: UIImage?
    @Published var chosenImageC: UIImage?
    @Published var chosenImageD: UIImage?
}





class ChosenCollageStyle: ObservableObject {@Published var chosenStyle: Int?}

class CollageBlocksAndViews {

    func blockForStyle() -> some View {return GeometryReader {geometry in HStack(spacing: 0) {Rectangle().fill(Color.gray).border(Color.black)}}}
    
    func onePhotoView(block: some View) -> some View {return block}
    func twoPhotoWide(block: some View) -> some View {return VStack(spacing:0){block; block}}
    func twoPhotoLong(block: some View) -> some View {return HStack(spacing:0){block; block}}
    func twoShortOneLong(block: some View) -> some View {return HStack(spacing:0){VStack(spacing:0){block; block}; block}}
    func twoNarrowOneWide(block: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){block; block}; block}}
    func fourPhoto(block: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){block; block}; HStack(spacing:0){block; block}}}
    
}

