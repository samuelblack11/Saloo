//
//  CollageFourView.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/29/22.
//

import Foundation
import SwiftUI

//2short1long
struct CollageFourView: View {

    @State private var showingImagePicker = false
    @State private var imageA: Image?
    @State private var imageB: Image?
    @State private var imageC: Image?
    @State private var imageNumber: Int?
    @State private var chosenImageA: UIImage?
    @State private var chosenImageB: UIImage?
    @State private var chosenImageC: UIImage?
    @State private var segueToWriteNote = false
    @Binding var collageImage: CollageImage!
    @Binding var chosenObject: CoverImageObject!
    @Binding var noteField: NoteField!
    
    
    
    var collageFourView: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                ZStack {
                    Rectangle().fill(.secondary)
                    Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                    imageA?.resizable()}
                    .onTapGesture {showingImagePicker = true; imageNumber = 1}
                    .frame(width: 150, height: 150)
                    .navigationTitle("Select 1 Photo")
                    .onChange(of: chosenImageA) { _ in loadImage(chosenImage: chosenImageA)}
                    .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImageA)}
                Divider()
                ZStack {
                    Rectangle().fill(.secondary)
                    Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                    imageB?.resizable()}
                    .onTapGesture {showingImagePicker = true; imageNumber = 2}
                    .frame(width: 150, height: 150)
                    .navigationTitle("Select 1 Photo")
                    .onChange(of: chosenImageB) { _ in loadImage(chosenImage: chosenImageB)}
                    .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImageB)}
                    }.frame(width: 150, height: 250)
            Divider()
            ZStack {
                Rectangle().fill(.secondary)
                Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                imageC?.resizable()}
                .onTapGesture {showingImagePicker = true; imageNumber = 3}
                .frame(width: 150, height: 300)
                .navigationTitle("Select 1 Photo")
                .onChange(of: chosenImageC) { _ in loadImage(chosenImage: chosenImageC)}
                .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImageC)}
        }.frame(width: 300, height: 300)
        
    }



    var body: some View {
        VStack {
            collageFourView
            Spacer()
            Button("Confirm Collage for Inside Cover") {
                segueToWriteNote  = true
                let theSnapShot = collageFourView.snapshot()
                print("********")
                print(theSnapShot)
                collageImage = CollageImage.init(collageImage: theSnapShot)
        }.padding(.bottom, 30).sheet(isPresented: $segueToWriteNote ) {WriteNoteView(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField)}
        }
    }

    func loadImage(chosenImage: UIImage?) {
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        if imageNumber == 1 {imageA = Image(uiImage: chosenImage)}
        if imageNumber == 2 {imageB = Image(uiImage: chosenImage)}
        if imageNumber == 3 {imageC = Image(uiImage: chosenImage)}

    }
    
}
