//
//  CollageStyleMenu.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/28/22.
//
// 

import Foundation
import SwiftUI

struct CollageStyleMenu: View {
    
    // The image, and it's components, selected by the user
    // Object for collection selected by user
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    @EnvironmentObject var chosenOccassion: Occassion
    @StateObject var collageImage = CollageImage()
    @State private var showConfirmFrontCover = false
    @State private var showCollageBuilder = false
    @State private var showImagePicker = false
    @State private var transitionVariable = false
    // Is front cover a personal photo? (selected from camera or library)
    // Tracks which collage type (#) was selected by the user
    @State private var collageStyles = []
    @State private var collageBlocks = CollageBlocksAndViews()
    @ObservedObject var gettingRecord = GettingRecord.shared

    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        collageBlocks.onePhotoView(block: collageBlocks.blockForStyle()).onTapGesture{collageImage.chosenStyle = 1; showCollageBuilder = true}
                        collageBlocks.twoPhotoWide(block: collageBlocks.blockForStyle()).onTapGesture{collageImage.chosenStyle = 2; showCollageBuilder = true}
                    }
                    HStack {
                        collageBlocks.twoPhotoLong(block: collageBlocks.blockForStyle()).onTapGesture{collageImage.chosenStyle = 3; showCollageBuilder = true}
                        collageBlocks.twoShortOneLong(block: collageBlocks.blockForStyle()).onTapGesture{collageImage.chosenStyle = 4; showCollageBuilder = true}
                    }
                    HStack {
                        collageBlocks.twoNarrowOneWide(block: collageBlocks.blockForStyle()).onTapGesture{collageImage.chosenStyle = 5; showCollageBuilder = true}
                        collageBlocks.fourPhoto(block: collageBlocks.blockForStyle()).onTapGesture{collageImage.chosenStyle = 6; showCollageBuilder = true}
                    }
                }
                LoadingOverlay()
            }
            .navigationTitle("Pick Collage Style").font(.headline).padding(.horizontal)
            .navigationBarItems(leading:Button {showConfirmFrontCover = true} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
        }
        .modifier(GettingRecordAlert())
        .environmentObject(collageImage)
        .fullScreenCover(isPresented: $showCollageBuilder) {CollageBuilder(showImagePicker: false).environmentObject(collageImage)}
        .fullScreenCover(isPresented: $showConfirmFrontCover) {ConfirmFrontCoverView()}
    }
}
