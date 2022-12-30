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
    @State private var chosenCollageStyle = 0
    let columns = [GridItem(.fixed(150)),GridItem(.fixed(150))]

    var body: some View {
        NavigationView {
            LazyVGrid(columns: columns, spacing: 10) {
                onePhotoView().onTapGesture{chosenCollageStyle = 1; viewTransitions.isShowingCollageOne = true}
                twoPhotoWide().onTapGesture{chosenCollageStyle = 2; viewTransitions.isShowingCollageTwo = true}
                twoPhotoLong().onTapGesture{chosenCollageStyle = 3; viewTransitions.isShowingCollageThree = true}
                threePhoto2Short1Long().onTapGesture{chosenCollageStyle = 4; viewTransitions.isShowingCollageFour = true}
                threePhoto2Narrow1Wide().onTapGesture{chosenCollageStyle = 5; viewTransitions.isShowingCollageFive = true}
                fourPhoto().onTapGesture{chosenCollageStyle = 6; viewTransitions.isShowingCollageSix = true}
            }
            .navigationTitle("Pick Collage Style").font(.headline).padding(.horizontal)
            .navigationBarItems(leading:
                Button {viewTransitions.isShowingConfirmFrontCover = true
            } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
            .fullScreenCover(isPresented: $viewTransitions.isShowingConfirmFrontCover) {
                ConfirmFrontCoverView(viewTransitions: viewTransitions, chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, pageCount: pageCount)
            }
            .frame(maxHeight: 800)
        }
        .fullScreenCover(isPresented: $viewTransitions.isShowingCollageOne) {CollageOneView(collageImage: $collageImage, chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
        .fullScreenCover(isPresented: $viewTransitions.isShowingCollageTwo) {CollageTwoView(collageImage: $collageImage, chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto,  viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
        .fullScreenCover(isPresented: $viewTransitions.isShowingCollageThree) {CollageThreeView(collageImage: $collageImage, chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
        .fullScreenCover(isPresented: $viewTransitions.isShowingCollageFour) {CollageFourView(collageImage: $collageImage, chosenObject: chosenObject,frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
        .fullScreenCover(isPresented: $viewTransitions.isShowingCollageFive) {CollageFiveView(collageImage: $collageImage, chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
        .fullScreenCover(isPresented: $viewTransitions.isShowingCollageSix) {CollageSixView(collageImage: $collageImage, chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
    }
}

extension CollageStyleMenu {
    // Building Blocks for each of the collage styles
    struct smallSquare: View {var body: some View {Rectangle().fill(Color.gray).frame(width: 75, height: 75).border(Color.black)}}
    struct wideRectangle: View {var body: some View {Rectangle().fill(Color.gray).frame(width: 150, height: 75).border(Color.black)}}
    struct tallRectangle: View {var body: some View {Rectangle().fill(Color.gray).frame(width: 75, height: 150).border(Color.black)}}
    struct largeSquare: View { var body: some View {VStack { Rectangle().fill(Color.gray).frame(width: 150, height: 150).padding(.vertical)}}}
    // Each of the collage styles
    struct onePhotoView: View {var body: some View {largeSquare()}}
    struct twoPhotoWide: View {var body: some View {VStack(spacing: 0){wideRectangle(); wideRectangle()}}}
    struct twoPhotoLong: View {var body: some View {HStack(spacing: 0){tallRectangle(); tallRectangle()}}}
    struct threePhoto2Short1Long: View {var body: some View {VStack(spacing: 0){VStack(spacing: 0){smallSquare(); smallSquare()}; tallRectangle()}}}
    struct threePhoto2Narrow1Wide : View {var body: some View {VStack(spacing: 0) {HStack(spacing: 0) {smallSquare(); smallSquare()}; wideRectangle()}}}
    struct fourPhoto: View {var body: some View {VStack(spacing: 0) {HStack(spacing: 0) {smallSquare(); smallSquare()}.border(Color.black); HStack(spacing: 0)  {smallSquare(); smallSquare()}.border(Color.black)}}}
}
