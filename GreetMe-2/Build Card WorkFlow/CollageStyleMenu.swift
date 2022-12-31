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
    @State private var menuSizeBlocks = CollageBuildingBlocks(menuSize: true)
    @State private var listofCollageStyles = []
        
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    let topLeft = (1,1)
    let topRight = (1,2)
    let midLeft = (2,1)
    let midRight = (2,2)
    let bottomLeft = (3,1)
    let bottomRight = (3,2)
    
    var body: some View {
        NavigationView {
            GridStack(rows: 3, columns: 2) { row, col in
            HStack(spacing:10) {
                //onePhotoView
                menuSizeBlocks.onePhotoView.onTapGesture{self.chosenCollageStyle = CollageStyles.choices.one; showCollageBuilder = true}
                //twoPhotoWide
                VStack(spacing:0){menuSizeBlocks.wideRectangle; menuSizeBlocks.wideRectangle}.onTapGesture{chosenCollageStyle = CollageStyles.choices.two; showCollageBuilder = true}
            }
            HStack(spacing:10) {
                //twoPhotoLong
                HStack(spacing:0){menuSizeBlocks.tallRectangle; menuSizeBlocks.tallRectangle}.onTapGesture{chosenCollageStyle = CollageStyles.choices.three; showCollageBuilder = true}
                //2Short1Long
                HStack(spacing:0){VStack(spacing:0){menuSizeBlocks.smallSquare; menuSizeBlocks.smallSquare}; menuSizeBlocks.tallRectangle}.onTapGesture{chosenCollageStyle = CollageStyles.choices.four; showCollageBuilder = true}
            }
            HStack(spacing:10) {
                //2Narrow1Wide
                VStack(spacing:0){HStack(spacing:0){menuSizeBlocks.smallSquare; menuSizeBlocks.smallSquare}; menuSizeBlocks.wideRectangle}.onTapGesture{chosenCollageStyle = CollageStyles.choices.five; showCollageBuilder = true}
                //fourPhoto
                HStack(spacing:0){menuSizeBlocks.smallSquare; menuSizeBlocks.smallSquare}; HStack(spacing:0){menuSizeBlocks.smallSquare; menuSizeBlocks.smallSquare}.onTapGesture{chosenCollageStyle = CollageStyles.choices.six; showCollageBuilder = true}
            }
            }
            .navigationTitle("Pick Collage Style").font(.headline).padding(.horizontal)
            .navigationBarItems(leading:Button {showConfirmFrontCover = true
            } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
            .fullScreenCover(isPresented: $showConfirmFrontCover) {
                ConfirmFrontCoverView(chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, pageCount: pageCount)
            }
            //.frame(maxHeight: 800)
        }
        .onAppear{createListofCollageStyles()}
        .frame(maxHeight: 800)
        .fullScreenCover(isPresented: $showCollageBuilder) {CollageBuilder(chosenObject: chosenObject, chosenCollection: chosenCollection, collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenCollageStyle: chosenCollageStyle!)}
    }
}

extension CollageStyleMenu {
    
    func createListofCollageStyles() {
        listofCollageStyles.append(menuSizeBlocks.onePhotoView)
        listofCollageStyles.append(menuSizeBlocks.twoPhotoWide)
        listofCollageStyles.append(menuSizeBlocks.twoPhotoLong)
        listofCollageStyles.append(menuSizeBlocks.twoShortOneLong)
        listofCollageStyles.append(menuSizeBlocks.twoNarrowOneWide)
        listofCollageStyles.append(menuSizeBlocks.fourPhoto)
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
