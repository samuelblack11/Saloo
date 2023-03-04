//
//  CollageBuilder2.swift
//  GreetMe-2
//
//  Created by Sam Black on 12/30/22.
//

import Foundation
import SwiftUI

struct CollageBuilder: View {
    // The image, and it's components, selected by the user
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    // Object for collection selected by user
    @EnvironmentObject var chosenOccassion: Occassion
    //@State public var chosenCollageStyle: CollageStyles.choices
    @EnvironmentObject var chosenStyle: ChosenCollageStyle
    // Variable for collageImage object
    @StateObject var collageImage = CollageImage()
    @StateObject var chosenImagesObject = ChosenImages()
    @State private var showCollageMenu = false
    @State private var showCollageBuilder = false
    @State private var showWriteNote = false
    @State var showImagePicker: Bool
    // Counts the page of the response being viewed by the user. 30 images per page maximum
    // Is front cover a personal photo? (selected from camera or library)
    // Tracks which collage type (#) was selected by the user
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

    
    var collageView: some View {
        VStack {chosenTemplate}.frame(minWidth: 100, maxWidth: 300, minHeight: 100,maxHeight: 325)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                collageView
                Spacer()
                Button("Confirm Collage for Inside Cover") {
                    showWriteNote = true
                    let theSnapShot = collageView.snapshot()
                    collageImage.collageImage = theSnapShot
                    //UIImageWriteToSavedPhotosAlbum(theSnapShot, nil, nil, nil)
                }.padding(.bottom, 30).fullScreenCover(isPresented: $showWriteNote ) {
                    WriteNoteView()}
            }
            .navigationBarItems(leading: Button {showCollageMenu = true} label: {
                Image(systemName: "chevron.left").foregroundColor(.blue)
                Text("Back")})
        }
        .environmentObject(collageImage)
        .environmentObject(chosenImagesObject)
        .fullScreenCover(isPresented: $showCollageMenu) {CollageStyleMenu()}
        }
    
    @ViewBuilder var chosenTemplate: some View {
        if chosenStyle.chosenStyle == 1 {onePhotoView(block: block1()) }
        if chosenStyle.chosenStyle == 2 {twoPhotoWide(block1: block1(),block2: block2())}
        if chosenStyle.chosenStyle == 3 {twoPhotoLong(block1: block1(),block2: block2())}
        if chosenStyle.chosenStyle == 4 { twoShortOneLong(block1: block1(), block2: block2(), block3: block3())}
        if chosenStyle.chosenStyle == 5 {twoNarrowOneWide(block1: block1(),block2: block2(),block3: block3())}
        if chosenStyle.chosenStyle == 6 {fourPhoto(block1: block1(),block2: block2(), block3: block3(), block4: block4())}
    }
}

extension CollageBuilder {
    
    func specifyImage(imageNumber: Int) -> UIImage? {
        let imageDict: [Int : UIImage?] = [
            1 : chosenImagesObject.chosenImageA,
            2 : chosenImagesObject.chosenImageB,
            3 : chosenImagesObject.chosenImageC,
            4 : chosenImagesObject.chosenImageD,
        ]
        return imageDict[imageNumber]!
    }

    
    func blockForPhotoSelection(imageForBlock: Image?, imageNum: Int) -> some View {
        return GeometryReader {geometry in
            ZStack(alignment: .center) {
                Rectangle().fill(Color.gray).border(Color.black)
                Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                imageForBlock?.resizable()
            }
        }
        .onTapGesture{self.showImagePicker.toggle(); imageNumber = imageNum}
        .onChange(of: specifyImage(imageNumber: imageNum)) { _ in
            loadImage(chosenImage: specifyImage(imageNumber: imageNum))
        }
    }
    
    func block1() -> some View {
        return blockForPhotoSelection(imageForBlock: imageA, imageNum: 1)
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(image: $chosenImagesObject.chosenImageA)
            }
    }
    
    func block2() -> some View {
        return blockForPhotoSelection(imageForBlock: imageB, imageNum: 2)
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(image: $chosenImagesObject.chosenImageB)
            }
    }
    
    func block3() -> some View {
        return blockForPhotoSelection(imageForBlock: imageC, imageNum: 3)
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(image: $chosenImagesObject.chosenImageC)
            }
    }
    
    func block4() -> some View {
        return blockForPhotoSelection(imageForBlock: imageD, imageNum: 4)
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(image: $chosenImagesObject.chosenImageD)
            }
    }
    
    func onePhotoView(block: some View) -> some View {return block}
    func twoPhotoWide(block1: some View, block2: some View) -> some View {return VStack(spacing:0){block1; block2}}
    func twoPhotoLong(block1: some View, block2: some View) -> some View {return HStack(spacing:0){block1; block2}}
    func twoShortOneLong(block1: some View, block2: some View, block3: some View) -> some View {return HStack(spacing:0){VStack(spacing:0){block1; block2}; block3}}
    func twoNarrowOneWide(block1: some View, block2: some View, block3: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){block1; block2}; block3}}
    func fourPhoto(block1: some View, block2: some View, block3: some View, block4: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){block1; block2}; HStack(spacing:0){block3; block4}}}
    


    func loadImage(chosenImage: UIImage?) {
        
        //chosenImagesObject.imagePlaceHolder = Image(systemName: "rays")
        
        print("called load image.....")
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        if imageNumber == 1 {imageA = Image(uiImage: chosenImage)}
        if imageNumber == 2 {imageB = Image(uiImage: chosenImage)}
        if imageNumber == 3 {imageC = Image(uiImage: chosenImage)}
        if imageNumber == 4 {imageD = Image(uiImage: chosenImage)}
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

