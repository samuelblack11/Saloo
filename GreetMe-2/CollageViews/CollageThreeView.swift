//
//  CollageThreeView.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/29/22.
//

import Foundation
import SwiftUI

struct CollageThreeView: View {
    
    @State private var showingImagePicker = false
    @State private var imageA: Image?
    @State private var imageB: Image?
    @State private var imageNumber: Int?
    @State private var chosenImageA: UIImage?
    @State private var chosenImageB: UIImage?

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Rectangle().fill(.secondary)
                Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                imageA?.resizable()}
                .onTapGesture {showingImagePicker = true; imageNumber = 1}
                .frame(width: 150, height: 250)
                .navigationTitle("Select 1 Photo")
                .onChange(of: chosenImageA) { _ in loadImage(chosenImage: chosenImageA)}
                .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImageA)}
            Divider()
            ZStack {
                Rectangle().fill(.secondary)
                Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                imageB?.resizable()}
                .onTapGesture {showingImagePicker = true; imageNumber = 2}
                .frame(width: 150, height: 250)
                .navigationTitle("Select 1 Photo")
                .onChange(of: chosenImageB) { _ in loadImage(chosenImage: chosenImageB)}
                .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $chosenImageB)}
                }.frame(width: 150, height: 250)}
    
    func loadImage(chosenImage: UIImage?) {
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        if imageNumber == 1 {imageA = Image(uiImage: chosenImage)}
        if imageNumber == 2 {imageB = Image(uiImage: chosenImage)}
        }
    }

struct CollageThreeView_Previews: PreviewProvider {
    static var previews: some View {
        CollageThreeView()
    }
}
