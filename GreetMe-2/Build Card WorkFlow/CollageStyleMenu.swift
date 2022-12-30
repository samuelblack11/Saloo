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
    // Object holding Bools for all views to be displayed.
    @ObservedObject var viewTransitions: ViewTransitions
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
    @State var chosenCollageStyle: CollageStyles.choices?
    //
    @State var menuSizeBlocks = CollageBuildingBlocks(menuSize: true)
    
    //let columns = [GridItem(.fixed(150)),GridItem(.fixed(150))]
    
    let columns = [GridItem(.flexible()),GridItem(.flexible())]


    var body: some View {
        NavigationView {
            LazyVGrid(columns: columns, spacing: 10) {
                //onePhotoView
                menuSizeBlocks.largeSquare.onTapGesture{chosenCollageStyle = CollageStyles.choices.one; viewTransitions.isShowingCollageBuilder = true}
                //twoPhotoWide
                VStack{menuSizeBlocks.wideRectangle; menuSizeBlocks.wideRectangle}.onTapGesture{chosenCollageStyle = CollageStyles.choices.two; viewTransitions.isShowingCollageBuilder = true}
                //twoPhotoLong
                HStack{menuSizeBlocks.tallRectangle; menuSizeBlocks.tallRectangle}.onTapGesture{chosenCollageStyle = CollageStyles.choices.three; viewTransitions.isShowingCollageBuilder = true}
                //2Short1Long
                HStack{VStack{menuSizeBlocks.smallSquare; menuSizeBlocks.smallSquare}; menuSizeBlocks.tallRectangle}.onTapGesture{chosenCollageStyle = CollageStyles.choices.four; viewTransitions.isShowingCollageBuilder = true}
                //2Narrow1Wide
                VStack{HStack{menuSizeBlocks.smallSquare; menuSizeBlocks.smallSquare}; menuSizeBlocks.wideRectangle}.onTapGesture{chosenCollageStyle = CollageStyles.choices.five; viewTransitions.isShowingCollageBuilder = true}
                //fourPhoto
                HStack{menuSizeBlocks.smallSquare; menuSizeBlocks.smallSquare}; HStack{menuSizeBlocks.smallSquare; menuSizeBlocks.smallSquare}.onTapGesture{chosenCollageStyle = CollageStyles.choices.six; viewTransitions.isShowingCollageBuilder = true}
            }
            .navigationTitle("Pick Collage Style").font(.headline).padding(.horizontal)
            .navigationBarItems(leading:Button {viewTransitions.isShowingConfirmFrontCover = true
            } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
            .fullScreenCover(isPresented: $viewTransitions.isShowingConfirmFrontCover) {
                ConfirmFrontCoverView(viewTransitions: viewTransitions, chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, pageCount: pageCount)
            }
            .frame(maxHeight: 800)
        }
        .fullScreenCover(isPresented: $viewTransitions.isShowingCollageBuilder) {CollageBuilder(viewTransitions: viewTransitions, chosenObject: chosenObject, chosenCollection: chosenCollection, collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenCollageStyle: chosenCollageStyle!)}
    }
}
