//
//  CollageTwoView.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/29/22.
//

import Foundation
import SwiftUI

struct CollageTwoView: View {
    @State private var showingImagePicker = false
    @State private var imageA: Image?
    @State private var imageB: Image?
    @State private var imageNumber: Int?
    @State private var chosenImageA: UIImage?
    @State private var chosenImageB: UIImage?
    @State private var segueToWriteNote = false
    @Binding var collageImage: CollageImage!
    @Binding var chosenObject: CoverImageObject!
    @Binding var frontCoverIsPersonalPhoto: Int
    @State var willHandWrite = false
    @State var eCardText: String = ""
    @State var printCardText: String = ""
    @ObservedObject var viewTransitions: ViewTransitions

    @State var chosenCollection: ChosenCollection


    var collageTwoView: some View {
        VStack(spacing:0 ) {
        ZStack {
            Rectangle().fill(.secondary)
            Text("Tap to select a picture").foregroundColor(.white).font(.headline)
            imageA?.resizable()
        }
            .onTapGesture {showingImagePicker = true; imageNumber = 1}
            .frame(width: 250, height: 150)
            .onChange(of: chosenImageA) { _ in loadImage(chosenImage: chosenImageA)}
            .fullScreenCover(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImageA)}
        Divider().frame(width: 250)
        ZStack {
            Rectangle().fill(.secondary)
            Text("Tap to select a picture").foregroundColor(.white).font(.headline)
            imageB?.resizable()
        }
            .onTapGesture {showingImagePicker = true; imageNumber = 2}
            .frame(width: 250, height: 150)
            .navigationBarItems(leading:
                                    Button {} label: {
                                    Image(systemName: "chevron.left").foregroundColor(.blue)
                                    Text("Back")
                                    })
            .onChange(of: chosenImageB) { _ in loadImage(chosenImage: chosenImageB)}
            .fullScreenCover(isPresented: $showingImagePicker) {ImagePicker(image: $chosenImageB)}
            }
        }

    var body: some View {
        NavigationView {
        VStack(spacing: 0) {
        collageTwoView
        Spacer()
        Button("Confirm Collage for Inside Cover") {
            //segueToWriteNote  = true
            viewTransitions.isShowingWriteNote = true
            let theSnapShot = collageTwoView.snapshot()
            collageImage = CollageImage.init(collageImage: theSnapShot)
        }.padding(.bottom, 30).sheet(isPresented: $viewTransitions.isShowingWriteNote ) {WriteNoteView(viewTransitions: viewTransitions, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: chosenObject, collageImage: collageImage, eCardText: $eCardText, printCardText: $printCardText, chosenCollection: chosenCollection)}
        }
        }
    }
    
    func loadImage(chosenImage: UIImage?) {
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        if imageNumber == 1 {imageA = Image(uiImage: chosenImage)}
        if imageNumber == 2 {imageB = Image(uiImage: chosenImage)}
        }
    }

