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
    //@Binding var collageImage: CollageImage!


    var body: some View {
        NavigationView {
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
            
            Button("Confirm Collage for Inside Cover") {
                segueToWriteNote  = true
                //collageImage = CollageImage.init(collageImage: <#T##Image#>)
            }.padding(.bottom, 30).sheet(isPresented: $segueToWriteNote ) {WriteNoteView()}
            }
        }
    
    func loadImage() {
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        image = Image(uiImage: chosenImage)
    }
    
}

struct CollageOneView_Previews: PreviewProvider {
    static var previews: some View {
        CollageOneView()
    }
}
