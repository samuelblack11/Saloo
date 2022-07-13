//
//  CollageOneView.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/29/22.
//

import Foundation
import SwiftUI

struct CollageOneView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var showingImagePicker = false
    @State private var image: Image?
    @State private var chosenImage: UIImage?
    @State private var segueToWriteNote = false
    @Binding var collageImage: CollageImage!
    @Binding var chosenObject: CoverImageObject!
    @Binding var noteField: NoteField!
    //var theSnapShot: Image!
    @Binding var frontCoverIsPersonalPhoto: Int
    @State var willHandWrite = false
    @State var eCardText: String = ""
    @State var printCardText: String = ""
    @State var fillColor = Color.secondary
    @State var searchObject: SearchParameter

    
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
                    Button {presentationMode.wrappedValue.dismiss()} label: {
                    Image(systemName: "chevron.left").foregroundColor(.blue)
                    Text("Back")
                    })
                .onChange(of: chosenImage) { _ in loadImage()}
                .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImage)}
        }
    var body: some View {
        NavigationView {
        VStack {
        collageOneView
        Spacer()
        Button("Confirm Collage for Inside Cover") {
            segueToWriteNote  = true
            let theSnapShot = collageOneView.snapshot()
            print("********")
            print(theSnapShot)
            collageImage = CollageImage.init(collageImage: theSnapShot)
        }.padding(.bottom, 30).sheet(isPresented: $segueToWriteNote ) {WriteNoteView(frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField, eCardText: $eCardText, printCardText: $printCardText, searchObject: searchObject)}
        }
        }

    }
    
    func loadImage() {
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        image = Image(uiImage: chosenImage)
    }
}
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-convert-a-swiftui-view-to-an-image
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        print("Target Size: \(targetSize)")
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

