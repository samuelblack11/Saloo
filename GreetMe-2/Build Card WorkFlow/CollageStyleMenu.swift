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
    @Binding var isShowingCollageMenu: Bool
    @State private var isShowingConfirmFrontCover = false
    @State private var isShowingCollageOne = false
    @State private var isShowingCollageTwo = false
    @State private var isShowingCollageThree = false
    @State private var isShowingCollageFour = false
    @State private var isShowingCollageFive = false
    @State private var isShowingCollageSix = false

    
    
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var collageImage: CollageImage!
    @State private var presentPrior = false
    @Binding var frontCoverIsPersonalPhoto: Int
    @State private var chosenCollageStyle = 0
    @Binding var chosenObject: CoverImageObject!
    @Binding var noteField: NoteField!
    @State var pageCount: Int = 1

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
                onePhotoView.onTapGesture{chosenCollageStyle = 1; isShowingCollageOne = true}
                twoPhotoWide.onTapGesture{chosenCollageStyle = 2; isShowingCollageTwo = true}
                twoPhotoLong.onTapGesture{chosenCollageStyle = 3; isShowingCollageThree = true}
                threePhoto2Short1Long.onTapGesture{chosenCollageStyle = 4; isShowingCollageFour = true}
                threePhoto2Narrow1Wide.onTapGesture{chosenCollageStyle = 5; isShowingCollageFive = true}
                fourPhoto.onTapGesture{chosenCollageStyle = 6; isShowingCollageSix = true}
            }
            .navigationTitle("Pick Collage Style")
            .font(.headline)
            .padding(.horizontal)
            .navigationBarItems(leading:
                Button {
                    print("Back button tapped")
                    presentationMode.wrappedValue.dismiss()
                    //presentPrior = true
                    isShowingConfirmFrontCover = true
                } label: {
                    Image(systemName: "chevron.left").foregroundColor(.blue)
                    Text("Back")
                })
            .sheet(isPresented: $isShowingConfirmFrontCover) {
                ConfirmFrontCoverView(isShowingConfirmFrontCover: $isShowingConfirmFrontCover, chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField, searchObject: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, pageCount: $pageCount)
            }
            .frame(maxHeight: 800)
        }

        .sheet(isPresented: $isShowingCollageOne) {CollageOneView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField,frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, searchObject: searchObject, isShowingCollageOne: $isShowingCollageOne)}
        .sheet(isPresented: $isShowingCollageTwo) {CollageTwoView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, searchObject: searchObject, isShowingCollageTwo: $isShowingCollageTwo)}
        .sheet(isPresented: $isShowingCollageThree) {CollageThreeView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, searchObject: searchObject, isShowingCollageThree: $isShowingCollageThree)}
        .sheet(isPresented: $isShowingCollageFour) {CollageFourView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, searchObject: searchObject, isShowingCollageFour: $isShowingCollageFour)}
        .sheet(isPresented: $isShowingCollageFive) {CollageFiveView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, searchObject: searchObject, isShowingCollageFive: $isShowingCollageFive)}
        .sheet(isPresented: $isShowingCollageSix) {CollageSixView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, searchObject: searchObject, isShowingCollageSix: $isShowingCollageSix)}
    }
}
