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

struct CollageImage {let collageImage: UIImage}
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

class ChosenCollageStyle: ObservableObject {@Published var chosenStyle: Int?}

class CollageBlocksAndViews {
    @State private var image: Image?
    @State private var chosenImage: UIImage?
    @State private var transitionVariable: Bool = false
    
    //init(image: Image?, chosenImage: UIImage?, transitionVariable: Bool) {
    //    self.image = image
    //    self.chosenImage = chosenImage
    //    self.transitionVariable = transitionVariable
    //}
    
    
    func blockForStyle() -> some View {return GeometryReader {geometry in HStack(spacing: 0) {Rectangle().fill(Color.gray).border(Color.black)}}}
    
    func blockForPhotoSelection() -> some View {
        return GeometryReader {geometry in
            ZStack(alignment: .center) {
                Rectangle().fill(Color.gray).border(Color.black)
                Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                self.image?.resizable()
            }
        }
        .onTapGesture{self.transitionVariable.toggle(); print("tap successful...\(self.transitionVariable)!!")}
        .onChange(of: chosenImage) { _ in self.loadImage()}
        //.fullScreenCover(isPresented: $transitionVariable) { ImagePicker(image: self.$chosenImage)}
    }
    
    
    func onePhotoView(block: some View) -> some View {return block}
    func twoPhotoWide(block: some View) -> some View {return VStack(spacing:0){block; block}}
    func twoPhotoLong(block: some View) -> some View {return HStack(spacing:0){block; block}}
    func twoShortOneLong(block: some View) -> some View {return HStack(spacing:0){VStack(spacing:0){block; block}; block}}
    func twoNarrowOneWide(block: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){blockForStyle(); blockForStyle()}; blockForStyle()}}
    func fourPhoto(block: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){blockForStyle(); blockForStyle()}; HStack(spacing:0){blockForStyle(); blockForStyle()}}}
    
    func loadImage() {
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        image = Image(uiImage: chosenImage)
    }
}




























// https://www.hackingwithswift.com/quick-start/swiftui/how-to-convert-a-swiftui-view-to-an-image
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        print("Target Size: \(targetSize)")
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
