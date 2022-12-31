//
//  CollageStyleMenu.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/28/22.
//
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-present-a-new-view-using-sheets

import Foundation
import SwiftUI

struct CollageStyleMenu: View {
    @State private var showConfirmFrontCover = false
    @State private var showCollageBuilder = false
    
    // The image, and it's components, selected by the user
    @ObservedObject var chosenObject: ChosenCoverImageObject
    // Object for collection selected by user
    @State var chosenCollection: ChosenCollection
    // Counts the page of the response being viewed by the user. 30 images per page maximum
    @State var pageCount: Int = 1
    // Variable for collageImage object
    @State var collageImage: CollageImage?
    // Is front cover a personal photo? (selected from camera or library)
    @Binding var frontCoverIsPersonalPhoto: Int
    // Tracks which collage type (#) was selected by the user
    @State private var collageBlocks = CBB()
    @State private var collageStyles = []
    @StateObject var chosenStyle = ChosenCollageStyle()
    
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    collageBlocks.onePhotoView(block: collageBlocks.blockForStyle()).onTapGesture{chosenStyle.chosenStyle = 1; showCollageBuilder = true}
                    collageBlocks.twoPhotoWide(block: collageBlocks.blockForStyle()).onTapGesture{chosenStyle.chosenStyle = 2; showCollageBuilder = true}
                }
                HStack {
                    collageBlocks.twoPhotoLong(block: collageBlocks.blockForStyle()).onTapGesture{chosenStyle.chosenStyle = 3; showCollageBuilder = true}
                    collageBlocks.twoShortOneLong(block: collageBlocks.blockForStyle()).onTapGesture{chosenStyle.chosenStyle = 4; showCollageBuilder = true}
                }
                HStack {
                    collageBlocks.twoNarrowOneWide(block: collageBlocks.blockForStyle()).onTapGesture{chosenStyle.chosenStyle = 5; showCollageBuilder = true}
                    collageBlocks.fourPhoto(block: collageBlocks.blockForStyle()).onTapGesture{chosenStyle.chosenStyle = 6; showCollageBuilder = true}
                }
            }
            .navigationTitle("Pick Collage Style").font(.headline).padding(.horizontal)
            .navigationBarItems(leading:Button {showConfirmFrontCover = true} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
        }
        .fullScreenCover(isPresented: $showCollageBuilder) {CollageBuilder(chosenObject: chosenObject, chosenCollection: chosenCollection, collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenCollageStyle: chosenStyle)}
        .fullScreenCover(isPresented: $showConfirmFrontCover) {ConfirmFrontCoverView(chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, pageCount: pageCount)}
    }
}

extension CollageStyleMenu {
    
}

