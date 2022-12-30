//
//  CollageBuilder.swift
//  GreetMe-2
//
//  Created by Sam Black on 12/30/22.
//

import Foundation
import SwiftUI

struct CollageBuilder: View {
    // Object holding Bools for all views to be displayed.
    @ObservedObject var viewTransitions: ViewTransitions
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
    @State var chosenCollageStyle: CollageStyles.choices
    // Create instance of CollageBuildingBlocks, with blocks sized to fit the CollageBuilder view (menuSize = false)
    @State var largeSizeBlocks = CollageBuildingBlocks(menuSize: false)
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
            // onePhoto
            case .one: largeSizeBlocks.createLargeSquare()
            // twoPhotoWide, stacked vertically
            case .two: VStack{largeSizeBlocks.wideRectangle; largeSizeBlocks.wideRectangle}
            // twoPhotoLong, stacked horizontally
            case .three: HStack{largeSizeBlocks.tallRectangle; largeSizeBlocks.tallRectangle}
            // 2Short1Long
            case .four: VStack{largeSizeBlocks.smallSquare; largeSizeBlocks.smallSquare}; largeSizeBlocks.tallRectangle
            // 2Narrow1Wide
            case .five: VStack{HStack{largeSizeBlocks.smallSquare; largeSizeBlocks.smallSquare}; largeSizeBlocks.wideRectangle}
            // fourPhoto
            case .six: HStack{largeSizeBlocks.smallSquare; largeSizeBlocks.smallSquare}; HStack{largeSizeBlocks.smallSquare; largeSizeBlocks.smallSquare}
        }
    }
    
    var body: some View {
        collageVisual
            .navigationBarItems(leading: Button {viewTransitions.isShowingCollageMenu = true; viewTransitions.isShowingCollageBuilder = false} label: {
                Image(systemName: "chevron.left").foregroundColor(.blue)
                Text("Back")
                })
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
