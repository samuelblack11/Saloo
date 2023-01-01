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
    @Binding var chosenImageA: UIImage?
    @Binding var chosenImageB: UIImage?
    @Binding var chosenImageC: UIImage?
    @Binding var chosenImageD: UIImage?
    @State var chosenImagesObject: ChosenImages?
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                chosenTemplate
                    .frame(minWidth: 100, maxWidth: 300, minHeight: 100,maxHeight: 325)
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
        .onAppear{chosenImagesObject = ChosenImages.init(chosenImageA: $chosenImageA, chosenImageB: $chosenImageB, chosenImageC: $chosenImageC, chosenImageD: $chosenImageD)}
            .fullScreenCover(isPresented: $showCollageMenu) {CollageStyleMenu(chosenObject: chosenObject, chosenCollection: chosenCollection, pageCount: pageCount, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)}
        }
}
extension CollageBuilder {
    
    //func blockForPhotoSelection(chosenImageForBlock: Binding<UIImage?>, imageForBlock: Image?, imageNum: Int) -> some View {
      //  return GeometryReader {geometry in
     //       ZStack(alignment: .center) {
      //          Rectangle().fill(Color.gray).border(Color.black)
      //          Text("Tap to select a picture").foregroundColor(.white).font(.headline)
     //           imageForBlock?.resizable()
     //       }
      //  }
     //   .onTapGesture{self.showImagePicker.toggle(); imageNumber = imageNum}
     //   .onChange(of: chosenImageForBlock) { _ in loadImage(chosenImage: chosenImageForBlock)}
     //   .fullScreenCover(isPresented: $showImagePicker) { ImagePicker(image: chosenImageForBlock)}
   // }
    
    

    func blockForPhotoSelection(chosenImages: ChosenImages, imageForBlock: Image?, imageNum: Int) -> some View {
        var chosenImageForBlock: Binding<UIImage?>
        if imageNum == 1 {chosenImageForBlock = chosenImages.$chosenImageA}
        if imageNum == 2 {chosenImageForBlock = chosenImages.$chosenImageB}
        if imageNum == 3 {chosenImageForBlock = chosenImages.$chosenImageC}
        if imageNum == 4 {chosenImageForBlock = chosenImages.$chosenImageD}

        
        
        //
        
        return GeometryReader {geometry in
            ZStack(alignment: .center) {
                Rectangle().fill(Color.gray).border(Color.black)
                Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                imageForBlock?.resizable()
            }
        }
        .onTapGesture{self.showImagePicker.toggle(); imageNumber = imageNum}
        .onChange(of: chosenImageForBlock) { _ in loadImage(chosenImage: $chosenImageForBlock)}
        .fullScreenCover(isPresented: $showImagePicker) {ImagePicker(image: chosenImageForBlock)}
    }
    
    func onePhotoView(block: some View) -> some View {return block}
    func twoPhotoWide(block1: some View, block2: some View) -> some View {return VStack(spacing:0){block1; block2}}
    func twoPhotoLong(block1: some View, block2: some View) -> some View {return HStack(spacing:0){block1; block2}}
    func twoShortOneLong(block1: some View, block2: some View, block3: some View) -> some View {return HStack(spacing:0){VStack(spacing:0){block1; block2}; block3}}
    func twoNarrowOneWide(block1: some View, block2: some View, block3: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){block1; block2}; block3}}
    func fourPhoto(block1: some View, block2: some View, block3: some View, block4: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){block1; block2}; HStack(spacing:0){block3; block4}}}
    
    @ViewBuilder var chosenTemplate: some View {
        if chosenCollageStyle.chosenStyle == 1 {onePhotoView(block: blockForPhotoSelection(chosenImageForBlock: chosenImageA, imageForBlock: imageA, imageNum: 1))}
        
        if chosenCollageStyle.chosenStyle == 2 {
            twoPhotoWide(block1: blockForPhotoSelection(chosenImageForBlock: chosenImageA, imageForBlock: imageA, imageNum: 1),
                         block2: blockForPhotoSelection(chosenImageForBlock: chosenImageB, imageForBlock: imageB, imageNum: 2))
        }
        
        if chosenCollageStyle.chosenStyle == 3 {
            twoPhotoLong(block1: blockForPhotoSelection(chosenImageForBlock: chosenImageA, imageForBlock: imageA, imageNum: 1),
                         block2: blockForPhotoSelection(chosenImageForBlock: chosenImageB, imageForBlock: imageB, imageNum: 2))
        }
        
        if chosenCollageStyle.chosenStyle == 4 {
            twoShortOneLong(block1: blockForPhotoSelection(chosenImageForBlock: chosenImageA, imageForBlock: imageA, imageNum: 1),
                            block2: blockForPhotoSelection(chosenImageForBlock: chosenImageB, imageForBlock: imageB, imageNum: 2),
                            block3: blockForPhotoSelection(chosenImageForBlock: chosenImageC, imageForBlock: imageC, imageNum: 3))
        }
        
        if chosenCollageStyle.chosenStyle == 5 {
            twoNarrowOneWide(block1: blockForPhotoSelection(chosenImageForBlock: chosenImageA, imageForBlock: imageA, imageNum: 1),
                             block2: blockForPhotoSelection(chosenImageForBlock: chosenImageB, imageForBlock: imageB, imageNum: 2),
                             block3: blockForPhotoSelection(chosenImageForBlock: chosenImageC, imageForBlock: imageC, imageNum: 3))
        }
        
        if chosenCollageStyle.chosenStyle == 6 {
            fourPhoto(block1: blockForPhotoSelection(chosenImageForBlock: chosenImageA, imageForBlock: imageA, imageNum: 1),
                      block2: blockForPhotoSelection(chosenImageForBlock: chosenImageB, imageForBlock: imageB, imageNum: 2),
                      block3: blockForPhotoSelection(chosenImageForBlock: chosenImageC, imageForBlock: imageC, imageNum: 3),
                      block4: blockForPhotoSelection(chosenImageForBlock: chosenImageD, imageForBlock: imageD, imageNum: 4))
        }
    }

    func loadImage(chosenImage: Binding<UIImage>) {
        print("called load image.....")
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        if imageNumber == 1 {imageA = Image(uiImage: chosenImage)}
        if imageNumber == 2 {imageB = Image(uiImage: chosenImage)}
        if imageNumber == 3 {imageC = Image(uiImage: chosenImage)}
        if imageNumber == 4 {imageD = Image(uiImage: chosenImage)}
    }
    
}
