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
    @State private var collageBlocks = CollageBuildingBlocks()
    @State private var collageStyles = []
    @State var chosenCollageStyle: CollageStyles.choices = .onePhotoView
    
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    collageBlocks.onePhotoStyle.onTapGesture{chosenCollageStyle  = .onePhotoView; showCollageBuilder = true}
                    collageBlocks.twoPhotoWideStyle.onTapGesture{chosenCollageStyle  = .twoPhotoWide; showCollageBuilder = true}
                }
                HStack {
                    collageBlocks.twoPhotoLongStyle.onTapGesture{chosenCollageStyle  = .twoPhotoLong; showCollageBuilder = true}
                    collageBlocks.twoNarrowOneWideStyle.onTapGesture{chosenCollageStyle  = .twoNarrowOneWide; showCollageBuilder = true}
                }
                HStack {
                    collageBlocks.twoShortOneLongStyle.onTapGesture{chosenCollageStyle  = .twoShortOneLong; showCollageBuilder = true}
                    collageBlocks.fourPhotoStyle.onTapGesture{chosenCollageStyle  = .fourPhoto; showCollageBuilder = true}
                }
            }
            .navigationTitle("Pick Collage Style").font(.headline).padding(.horizontal)
            .navigationBarItems(leading:Button {showConfirmFrontCover = true} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
        }
        .fullScreenCover(isPresented: $showCollageBuilder) {CollageBuilder(chosenObject: chosenObject, chosenCollection: chosenCollection, collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenCollageStyle: chosenCollageStyle)}
        .fullScreenCover(isPresented: $showConfirmFrontCover) {ConfirmFrontCoverView(chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, pageCount: pageCount)}
    }
}

