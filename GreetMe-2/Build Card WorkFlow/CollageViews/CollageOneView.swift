//
//  CollageOneView.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/29/22.
//

import Foundation
import SwiftUI

struct CollageOneView: View {
    @State private var showWriteNote = false
    @State private var showingImagePicker = false
    @State private var image: Image?
    @State private var chosenImage: UIImage?
    @Binding var collageImage: CollageImage!
    @ObservedObject var chosenObject: ChosenCoverImageObject
    //var theSnapShot: Image!
    @Binding var frontCoverIsPersonalPhoto: Int
    @State var eCardText: String = ""
    @State var printCardText: String = ""
    @State var fillColor = Color.secondary
    @State var chosenCollection: ChosenCollection


    
    func changeFillColor() {
        fillColor = Color.white
    }

    var collageOneView: some View {
        ZStack {
            Rectangle().fill(fillColor)
                //.onChange(of: image, perform: changeFillColor())
                Text("Tap to select a picture")
                    .foregroundColor(.white)
                    .font(.headline)
                image?
                .resizable()
                //.scaledToFit()
                }
                .onTapGesture {showingImagePicker = true}
                .frame(width: 300, height: 300)
                .navigationBarItems(leading:
                    Button {} label: {
                    Image(systemName: "chevron.left").foregroundColor(.blue)
                    Text("Back")
                    })
                .onChange(of: chosenImage) { _ in loadImage()}
                .fullScreenCover(isPresented: $showingImagePicker) { ImagePicker(image: chosenImage)}
        }
    var body: some View {
        NavigationView {
        VStack {
        collageOneView
        Spacer()
        Button("Confirm Collage for Inside Cover") {
            showWriteNote = true
            let theSnapShot = collageOneView.snapshot()
            collageImage = CollageImage.init(collageImage: theSnapShot)
        }.padding(.bottom, 30).fullScreenCover(isPresented: $showWriteNote ) {
            WriteNoteView(frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: chosenObject, collageImage: collageImage, eCardText: $eCardText, printCardText: $printCardText, chosenCollection: chosenCollection)}
        }
        }

    }
    
    func loadImage() {
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        image = Image(uiImage: chosenImage)
    }
}
