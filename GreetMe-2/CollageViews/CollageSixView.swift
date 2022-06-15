//
//  CollageSixView.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/29/22.
//

import Foundation
import SwiftUI

struct CollageSixView: View {
    @State private var showingImagePicker = false
    @State private var imageA: Image?
    @State private var imageB: Image?
    @State private var imageC: Image?
    @State private var imageD: Image?
    @State private var imageNumber: Int?
    @State private var chosenImageA: UIImage?
    @State private var chosenImageB: UIImage?
    @State private var chosenImageC: UIImage?
    @State private var chosenImageD: UIImage?
    @State private var segueToWriteNote = false
    @Binding var collageImage: CollageImage!
    @Binding var chosenObject: CoverImageObject!
    @Binding var noteField: NoteField!
    @Binding var frontCoverIsPersonalPhoto: Int


    var collageSixView: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ZStack {
                        Rectangle().fill(.secondary)
                        Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                        imageA?.resizable()}
                        .onTapGesture {showingImagePicker = true; imageNumber = 1}
                        .frame(width: 150, height: 150)
                        .onChange(of: chosenImageA) { _ in loadImage(chosenImage: chosenImageA)}
                        .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImageA)}
                    Divider()
                    ZStack {
                        Rectangle().fill(.secondary)
                        Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                        imageB?.resizable()}
                        .onTapGesture {showingImagePicker = true; imageNumber = 2}
                        .frame(width: 150, height: 150)
                        .onChange(of: chosenImageB) { _ in loadImage(chosenImage: chosenImageB)}
                        .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImageB)}
                        }.frame(width: 150, height: 150)
                    Divider()
                    HStack(spacing: 0) {
                        ZStack {
                        Rectangle().fill(.secondary)
                        Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                        imageC?.resizable()}
                        .onTapGesture {showingImagePicker = true; imageNumber = 3}
                        .frame(width: 150, height: 150)
                        .onChange(of: chosenImageC) { _ in loadImage(chosenImage: chosenImageC)}
                        .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImageC)}
                    Divider()
                    ZStack {
                        Rectangle().fill(.secondary)
                        Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                        imageD?.resizable()}
                        .onTapGesture {showingImagePicker = true; imageNumber = 4}
                        .frame(width: 150, height: 150)
                        .onChange(of: chosenImageD) { _ in loadImage(chosenImage: chosenImageD)}
                        .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImageD)}
                        }.frame(width: 150, height: 150)
            }.frame(width: 300, height: 300)
    }


    var body: some View {
        VStack {
            collageSixView
            Spacer()
            Button("Confirm Collage for Inside Cover") {
                segueToWriteNote  = true
                let theSnapShot = collageSixView.snapshot()
                print("********")
                print(theSnapShot)
                collageImage = CollageImage.init(collageImage: theSnapShot)
            }.padding(.bottom, 30).sheet(isPresented: $segueToWriteNote ) {WriteNoteView(frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField)}
        }
    }
        
        
        
        func loadImage(chosenImage: UIImage?) {
            guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
            if imageNumber == 1 {imageA = Image(uiImage: chosenImage)}
            if imageNumber == 2 {imageB = Image(uiImage: chosenImage)}
            if imageNumber == 3 {imageC = Image(uiImage: chosenImage)}
            if imageNumber == 4 {imageD = Image(uiImage: chosenImage)}
        }

}
