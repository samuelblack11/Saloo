//
//  CollageStyleMenu.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/28/22.
//
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-present-a-new-view-using-sheets

import Foundation
import SwiftUI

struct CollageImage {
    let collageImage: UIImage
}

struct CollageStyleMenu: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var collageImage: CollageImage!
    @State private var presentPrior = false
    @Binding var frontCoverIsPersonalPhoto: Int
    @State private var chosenCollageStyle = 0
    @State private var collageOne = false
    @State private var collageTwo = false
    @State private var collageThree = false
    @State private var collageFour = false
    @State private var collageFive = false
    @State private var collageSix = false
    @Binding var chosenObject: CoverImageObject!
    @Binding var noteField: NoteField!
    @State var searchObject: SearchParameter

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
                onePhotoView.onTapGesture{chosenCollageStyle = 1; collageOne = true}
                twoPhotoWide.onTapGesture{chosenCollageStyle = 2; collageTwo = true}
                twoPhotoLong.onTapGesture{chosenCollageStyle = 3; collageThree = true}
                threePhoto2Short1Long.onTapGesture{chosenCollageStyle = 4; collageFour = true}
                threePhoto2Narrow1Wide.onTapGesture{chosenCollageStyle = 5; collageFive = true}
                fourPhoto.onTapGesture{chosenCollageStyle = 6; collageSix = true}
            }
            .navigationTitle("Pick Collage Style")
            .font(.headline)
            .padding(.horizontal)
            .navigationBarItems(leading:
                Button {
                    print("Back button tapped")
                    presentationMode.wrappedValue.dismiss()
                    //presentPrior = true
                } label: {
                    Image(systemName: "chevron.left").foregroundColor(.blue)
                    Text("Back")
                })
            .sheet(isPresented: $presentPrior) {
                ConfirmFrontCoverView(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField, searchObject: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
            }
            .frame(maxHeight: 800)
        }

        .sheet(isPresented: $collageOne) {CollageOneView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField,frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, searchObject: searchObject)}
        .sheet(isPresented: $collageTwo) {CollageTwoView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, searchObject: searchObject)}
        .sheet(isPresented: $collageThree) {CollageThreeView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, searchObject: searchObject)}
        .sheet(isPresented: $collageFour) {CollageFourView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, searchObject: searchObject)}
        .sheet(isPresented: $collageFive) {CollageFiveView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, searchObject: searchObject)}
        .sheet(isPresented: $collageSix) {CollageSixView(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, searchObject: searchObject)}
    }
}
