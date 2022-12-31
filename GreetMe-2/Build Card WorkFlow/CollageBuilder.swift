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
    @State public var chosenCollageStyle: CollageStyles.choices
    @State private var collageBlocks = CBB()

    
    
    // Create instance of CollageBuildingBlocks, with blocks sized to fit the CollageBuilder view (menuSize = false)
    @State private var showingImagePicker = false
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

    // Creates collage visual based on user selction from CollageStyleMenu
    @ViewBuilder var collageVisual: some View {
        switch chosenCollageStyle {
            case .onePhotoView: collageBlocks.onePhotoView(block: collageBlocks.blockForPhotoSelection())
            //case .twoPhotoWide: collageBlocks.twoPhotoWide
            //case .twoPhotoLong: collageBlocks.twoPhotoLong
            //case .twoShortOneLong: collageBlocks.twoShortOneLong
            //case .twoNarrowOneWide: collageBlocks.twoNarrowOneWide
            //case .fourPhoto: collageBlocks.fourPhoto
        }
    }
    
    
    
    func createCollageTemplate(style: CollageStyles.choices) {
        
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                collageVisual
                Spacer()
                Button("Confirm Collage for Inside Cover") {
                    showWriteNote = true
                    let theSnapShot = collageVisual.snapshot()
                    collageImage = CollageImage.init(collageImage: theSnapShot)
                }.padding(.bottom, 30).fullScreenCover(isPresented: $showWriteNote ) {
                    WriteNoteView(frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: chosenObject, collageImage: collageImage, eCardText: $eCardText, printCardText: $printCardText, chosenCollection: chosenCollection)}
            }
            .onAppear{print("---"); print(chosenCollageStyle)}
            .navigationBarItems(leading: Button {showCollageMenu = true} label: {
                Image(systemName: "chevron.left").foregroundColor(.blue)
                Text("Back")})
        }
    }
}

extension CollageBuilder {

    func loadImage(chosenImage: UIImage?) {
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        if imageNumber == 1 {imageA = Image(uiImage: chosenImage)}
        if imageNumber == 2 {imageB = Image(uiImage: chosenImage)}
        if imageNumber == 3 {imageC = Image(uiImage: chosenImage)}
        if imageNumber == 4 {imageD = Image(uiImage: chosenImage)}
    }
    
}
