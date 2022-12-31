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
    @State var chosenCollageStyle: CollageStyles.choices?
    //
    @State private var menuSizeBlocks = CollageBuildingBlocks()
    @State private var collageStyles = []
    
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    let topLeft = (1,1)
    let topRight = (1,2)
    let midLeft = (2,1)
    let midRight = (2,2)
    let bottomLeft = (3,1)
    let bottomRight = (3,2)
    
    //.onTapGesture{self.chosenCollageStyle = CollageStyles.choices.one; showCollageBuilder = true}
    
    var body: some View {
        NavigationView {
            //LazyVGrid(columns: columns, spacing: 10) {
            GridStack(rows: 3, columns: 2) { row, col in
                //menuSizeBlocks.onePhotoView.onTapGesture{self.chosenCollageStyle = CollageStyles.choices.one; showCollageBuilder = true}
                //menuSizeBlocks.twoPhotoWide
                //menuSizeBlocks.twoPhotoLong
                menuSizeBlocks.twoNarrowOneWide
                //menuSizeBlocks.twoShortOneLong
                //menuSizeBlocks.fourPhoto
            }
            .navigationTitle("Pick Collage Style").font(.headline).padding(.horizontal)
            .fullScreenCover(isPresented: $showConfirmFrontCover) {ConfirmFrontCoverView(chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, pageCount: pageCount)}
            }
            //.onAppear{createListofCollageStyles()}
            .navigationBarItems(leading:Button {showConfirmFrontCover = true
            } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
            .fullScreenCover(isPresented: $showCollageBuilder) {CollageBuilder(chosenObject: chosenObject, chosenCollection: chosenCollection, collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenCollageStyle: chosenCollageStyle!)}
        }
}

extension CollageStyleMenu {
    
    func createListofCollageStyles() {
        collageStyles.append(menuSizeBlocks.onePhotoView)
        collageStyles.append(menuSizeBlocks.twoPhotoWide)
        collageStyles.append(menuSizeBlocks.twoPhotoLong)
        collageStyles.append(menuSizeBlocks.twoShortOneLong)
        collageStyles.append(menuSizeBlocks.twoNarrowOneWide)
        collageStyles.append(menuSizeBlocks.fourPhoto)
    }
    
    // HackingWithSwift SwiftUI by Example, Page 230
    struct GridStack<Content: View>: View {
       let rows: Int
       let columns: Int
       let content: (Int, Int) -> Content
       var body: some View {
          VStack {
             ForEach(0 ..< rows, id: \.self) { row in
                HStack {
                   ForEach(0 ..< columns, id: \.self) { column in
                      content(row, column)
                   }
                }
             }
          }
       }
    init(rows: Int, columns: Int, @ViewBuilder content:
    @escaping (Int, Int) -> Content) {
          self.rows = rows
          self.columns = columns
          self.content = content
        }
    }
}
