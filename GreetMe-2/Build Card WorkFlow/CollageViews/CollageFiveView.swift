//
//  CollageFiveView.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/29/22.
//

import Foundation
import SwiftUI


//2narrow1wide
struct CollageFiveView: View {
    @Environment(\.presentationMode) var presentationMode

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
    @Binding var frontCoverIsPersonalPhoto: Int
    @State var willHandWrite = false
    @State var eCardText: String = ""
    @State var printCardText: String = ""
    @State var searchObject: SearchParameter


    var collageFiveView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ZStack {
                    Rectangle().fill(.secondary)
                    Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                    imageA?.resizable()}
                    .onTapGesture {showingImagePicker = true; imageNumber = 1}
                    .frame(width: 150, height: 150)
                    .navigationBarItems(leading:
                                        Button {presentationMode.wrappedValue.dismiss()} label: {
                                        Image(systemName: "chevron.left").foregroundColor(.blue)
                                        Text("Back")
                                        })
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
                    }.frame(width: 300, height: 150)
            Divider()
            ZStack {
                Rectangle().fill(.secondary)
                Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                imageC?.resizable()}
                .onTapGesture {showingImagePicker = true; imageNumber = 3}
                .frame(width: 300, height: 150)
                .onChange(of: chosenImageC) { _ in loadImage(chosenImage: chosenImageC)}
                .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImageC)}
        }.frame(width: 300, height: 300)
        
    }

    
    var body: some View {
        NavigationView {
        collageFiveView
        Spacer()
        Button("Confirm Collage for Inside Cover") {
            segueToWriteNote  = true
            let theSnapShot = collageFiveView.snapshot()
            print("********")
            print(theSnapShot)
            collageImage = CollageImage.init(collageImage: theSnapShot)
        }.padding(.bottom, 30).sheet(isPresented: $segueToWriteNote ) {WriteNoteView(frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField, eCardText: $eCardText, printCardText: $printCardText, searchObject: searchObject)}
    }
    }

    func loadImage(chosenImage: UIImage?) {
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        if imageNumber == 1 {imageA = Image(uiImage: chosenImage)}
        if imageNumber == 2 {imageB = Image(uiImage: chosenImage)}
        if imageNumber == 3 {imageC = Image(uiImage: chosenImage)}

    }
    
}

