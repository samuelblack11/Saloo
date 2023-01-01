//
//  CollageBuilder2.swift
//  GreetMe-2
//
//  Created by Sam Black on 12/30/22.
//

import Foundation
import SwiftUI

struct CollageBuilder: View {
    @State private var showCollageMenu = false
    @State private var showCollageBuilder = false
    @State private var showWriteNote = false
    @State var showImagePicker: Bool
    // The image, and it's components, selected by the user
    @ObservedObject var chosenObject: ChosenCoverImageObject
    // Object for collection selected by user
    @State var chosenCollection: ChosenCollection
    // Counts the page of the response being viewed by the user. 30 images per page maximum
    @State var pageCount: Int = 1
    // Variable for collageImage object
    @Binding var collageImage: CollageImage?
    // Is front cover a personal photo? (selected from camera or library)
    @Binding var frontCoverIsPersonalPhoto: Int
    // Tracks which collage type (#) was selected by the user
    //@State public var chosenCollageStyle: CollageStyles.choices
    @ObservedObject public var chosenCollageStyle: ChosenCollageStyle
    @State private var cBB = CollageBlocksAndViews()

    // Create instance of CollageBuildingBlocks, with blocks sized to fit the CollageBuilder view (menuSize = false)
    @State private var image: Image?
    @State private var chosenImage: UIImage?
    @State var eCardText: String = ""
    @State var printCardText: String = ""
    @State var fillColor = Color.secondary
    @State private var imageA: Image?
    @State private var imageB: Image?
    @State private var imageC: Image?
    @State private var imageD: Image?
    @State private var imageNumber: Int?
    @State private var chosenImageA: UIImage?
    @State private var chosenImageB: UIImage?
    @State private var chosenImageC: UIImage?
    @State private var chosenImageD: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                chosenTemplate
                Spacer()
                Button("Confirm Collage for Inside Cover") {
                    showWriteNote = true
                    let theSnapShot = chosenTemplate.snapshot()
                    collageImage = CollageImage.init(collageImage: theSnapShot)
                }.padding(.bottom, 30).fullScreenCover(isPresented: $showWriteNote ) {
                    WriteNoteView(frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: chosenObject, collageImage: collageImage, eCardText: $eCardText, printCardText: $printCardText, chosenCollection: chosenCollection)}
            }
            .navigationBarItems(leading: Button {showCollageMenu = true} label: {
                Image(systemName: "chevron.left").foregroundColor(.blue)
                Text("Back")})
        }
        .fullScreenCover(isPresented: $showCollageMenu) {CollageStyleMenu(chosenObject: chosenObject, chosenCollection: chosenCollection, pageCount: pageCount, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)}
    }
}

extension CollageBuilder {
    
    @ViewBuilder var chosenTemplate: some View {
        if chosenCollageStyle.chosenStyle == 1 {cBB.onePhotoView(block: cBB.blockForPhotoSelection())}
        if chosenCollageStyle.chosenStyle == 2 {cBB.twoPhotoWide(block: cBB.blockForPhotoSelection())}
        if chosenCollageStyle.chosenStyle == 3 {cBB.twoPhotoLong(block: cBB.blockForPhotoSelection())}
        if chosenCollageStyle.chosenStyle == 4 {cBB.twoShortOneLong(block: cBB.blockForPhotoSelection())}
        if chosenCollageStyle.chosenStyle == 5 {cBB.twoNarrowOneWide(block: cBB.blockForPhotoSelection())}
        if chosenCollageStyle.chosenStyle == 6 {cBB.fourPhoto(block: cBB.blockForPhotoSelection())}
    }

    func loadImage(chosenImage: UIImage?) {
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        if imageNumber == 1 {imageA = Image(uiImage: chosenImage)}
        if imageNumber == 2 {imageB = Image(uiImage: chosenImage)}
        if imageNumber == 3 {imageC = Image(uiImage: chosenImage)}
        if imageNumber == 4 {imageD = Image(uiImage: chosenImage)}
    }
    
}
