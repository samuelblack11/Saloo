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
    @ObservedObject var viewTransitions: ViewTransitions
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var collageImage: CollageImage!
    @State private var presentPrior = false
    @Binding var frontCoverIsPersonalPhoto: Int
    @State private var chosenCollageStyle = 0
    @Binding var chosenObject: CoverImageObject!
    @Binding var noteField: NoteField!
    @State var pageCount: Int = 1
    @State var chosenCollection: ChosenCollection

    let columns = [GridItem(.fixed(150)),GridItem(.fixed(150))]
    
    let onePhotoView: some View = VStack { Rectangle().fill(Color.gray).frame(width: 150, height: 150).padding(.vertical) }
    let twoPhotoWide: some View = VStack(spacing: 0) {
        Rectangle().fill(Color.gray).frame(width: 150, height: 75).border(Color.black)
        Rectangle().fill(Color.gray).frame(width: 150, height: 75).border(Color.black)
    }
    let twoPhotoLong: some View = VStack {HStack(spacing: 0)  {
        Rectangle().fill(Color.gray).frame(width: 75, height: 150).border(Color.black)
        Rectangle().fill(Color.gray).frame(width: 75, height: 150).border(Color.black)
    } }
    let threePhoto2Short1Long: some View = VStack { HStack(spacing: 0)  {
        VStack(spacing: 0) {
            Rectangle().fill(Color.gray).frame(width: 75, height: 75).border(Color.black)
            Rectangle().fill(Color.gray).frame(width: 75, height: 75).border(Color.black)
        }
        Rectangle().fill(Color.gray).frame(width: 75, height: 150).border(Color.black)
    } }
    let threePhoto2Narrow1Wide:  some View = VStack(spacing: 0)  {
        HStack(spacing: 0)  {
            Rectangle().fill(Color.gray).frame(width: 75, height: 75).border(Color.black)
            Rectangle().fill(Color.gray).frame(width: 75, height: 75).border(Color.black)
        }
        Rectangle().fill(Color.gray).frame(width: 150, height: 75).border(Color.black)
    }
    
    let fourPhoto: some View = VStack(spacing: 0)  {
        HStack(spacing: 0)  {
            Rectangle().fill(Color.gray).frame(width: 75, height: 75).border(Color.black)
            Rectangle().fill(Color.gray).frame(width: 75, height: 75).border(Color.black)
            }.border(Color.black)
        HStack(spacing: 0)  {
            Rectangle().fill(Color.gray).frame(width: 75, height: 75).border(Color.black)
            Rectangle().fill(Color.gray).frame(width: 75, height: 75).border(Color.black)
        }.border(Color.black)
    }.border(Color.black)


    var body: some View {
        NavigationView {
            LazyVGrid(columns: columns, spacing: 10) {
                onePhotoView.onTapGesture{chosenCollageStyle = 1; viewTransitions.isShowingCollageOne = true}
                twoPhotoWide.onTapGesture{chosenCollageStyle = 2; viewTransitions.isShowingCollageTwo = true}
                twoPhotoLong.onTapGesture{chosenCollageStyle = 3; viewTransitions.isShowingCollageThree = true}
                threePhoto2Short1Long.onTapGesture{chosenCollageStyle = 4; viewTransitions.isShowingCollageFour = true}
                threePhoto2Narrow1Wide.onTapGesture{chosenCollageStyle = 5; viewTransitions.isShowingCollageFive = true}
                fourPhoto.onTapGesture{chosenCollageStyle = 6; viewTransitions.isShowingCollageSix = true}
            }
            .navigationTitle("Pick Collage Style")
            .font(.headline)
            .padding(.horizontal)
            .navigationBarItems(leading:
                Button {
                    print("Back button tapped")
                    presentationMode.wrappedValue.dismiss()
                    //presentPrior = true
                viewTransitions.isShowingConfirmFrontCover = true
                } label: {
                    Image(systemName: "chevron.left").foregroundColor(.blue)
                    Text("Back")
                })
            .sheet(isPresented: $viewTransitions.isShowingConfirmFrontCover) {
                ConfirmFrontCoverView(viewTransitions: viewTransitions, chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, pageCount: $pageCount)
            }
            .frame(maxHeight: 800)
        }

        .sheet(isPresented: $viewTransitions.isShowingCollageOne) {CollageOneView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField,frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
        .sheet(isPresented: $viewTransitions.isShowingCollageTwo) {CollageTwoView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto,  viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
        .sheet(isPresented: $viewTransitions.isShowingCollageThree) {CollageThreeView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
        .sheet(isPresented: $viewTransitions.isShowingCollageFour) {CollageFourView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
        .sheet(isPresented: $viewTransitions.isShowingCollageFive) {CollageFiveView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
        .sheet(isPresented: $viewTransitions.isShowingCollageSix) {CollageSixView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
    }
}
