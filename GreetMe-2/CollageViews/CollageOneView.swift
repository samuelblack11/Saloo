//
//  CollageOneView.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/29/22.
//

import Foundation
import SwiftUI

struct CollageOneView: View {
    
    @State private var showingImagePicker = false
    @State private var image: Image?
    @State private var chosenImage: UIImage?
    @State private var segueToWriteNote = false
    @Binding var collageImage: CollageImage!
    @Binding var chosenObject: CoverImageObject!
    @Binding var noteField: NoteField!
    //var theSnapShot: Image!


    var collageOneView: some View {
        ZStack {
                Rectangle().fill(.secondary)
                Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                image?.resizable().scaledToFill()
                }
                .onTapGesture {showingImagePicker = true}
                .frame(width: 300, height: 300)
                .navigationTitle("Select 1 Photo")
                .onChange(of: chosenImage) { _ in loadImage()}
                .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImage)}
        }
    var body: some View {
        VStack {
        collageOneView
        Spacer()
        Button("Confirm Collage for Inside Cover") {
            segueToWriteNote  = true
            let theSnapShot = collageOneView.snapshot()
            print("********")
            print(theSnapShot)
            collageImage = CollageImage.init(collageImage: Image(uiImage: theSnapShot))
            }.padding(.bottom, 30).sheet(isPresented: $segueToWriteNote ) {WriteNoteView(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField)
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
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

