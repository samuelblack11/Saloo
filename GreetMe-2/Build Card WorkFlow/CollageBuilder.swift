//
//  CollageBuilder.swift
//  GreetMe-2
//
//  Created by Sam Black on 12/30/22.
//

import Foundation
import SwiftUI


struct CollageBuilder: View {
    // Object holding Bools for all views to be displayed.
    @ObservedObject var viewTransitions: ViewTransitions
    // The image, and it's components, selected by the user
    @ObservedObject var chosenObject: ChosenCoverImageObject
    // Object for collection selected by user
    @State var chosenCollection: ChosenCollection
    // Counts the page of the response being viewed by the user. 30 images per page maximum
    @State var pageCount: Int = 1
    // Variable for collageImage object
    @Binding var collageImage: CollageImage?
    // Is front cover a personal photo? (selected from camera or library)
    @Binding var frontCoverIsPersonalPhoto: Int
    // Tracks which collage type (#) was selected by the user
    @State var chosenCollageStyle: CollageStyles.choices
    // Creates collage visual based on user selction from CollageStyleMenu
    @ViewBuilder var collageVisual: some View {
        switch chosenCollageStyle {
            case .one: onePhotoView()
            case .two: twoPhotoWide()
            case .three: twoPhotoLong()
            case .four: threePhoto2Short1Long()
            case .five: threePhoto2Narrow1Wide()
            case .six: fourPhoto()
        }
    }
    
    @State private var showingImagePicker = false
    @State private var image: Image?
    @State private var chosenImage: UIImage?
    @State var eCardText: String = ""
    @State var printCardText: String = ""
    @State var fillColor = Color.secondary
    
    var body: some View {
        collageVisual
    }
}

extension CollageBuilder {
    // Building Blocks for each of the collage styles
    struct smallSquare: View {var body: some View {GeometryReader { geometry in
        HStack(spacing: 0) {Rectangle().fill(Color.gray).frame(width: geometry.size.width * 0.45, height: geometry.size.width * 0.45 ).border(Color.black)}}}
    }
    
    struct wideRectangle: View {var body: some View {GeometryReader { geometry in
        HStack(spacing: 0) {Rectangle().fill(Color.gray).frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.45).border(Color.black)}}}
    }
    
    struct tallRectangle: View {var body: some View {GeometryReader { geometry in
        HStack(spacing: 0) {Rectangle().fill(Color.gray).frame(width: geometry.size.width * 0.45, height: geometry.size.width * 0.9).border(Color.black)}}}
        }
    
    struct largeSquare: View {var body: some View {GeometryReader { geometry in
        VStack {Rectangle().fill(Color.gray).frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9 ).padding(.vertical)}}}
    }
        
    // Each of the collage styles
    struct onePhotoView: View {var body: some View {largeSquare()}}
    struct twoPhotoWide: View {var body: some View {VStack(spacing: 0){wideRectangle(); wideRectangle()}}}
    struct twoPhotoLong: View {var body: some View {HStack(spacing: 0){tallRectangle(); tallRectangle()}}}
    struct threePhoto2Short1Long: View {var body: some View {VStack(spacing: 0){VStack(spacing: 0){smallSquare(); smallSquare()}; tallRectangle()}}}
    struct threePhoto2Narrow1Wide : View {var body: some View {VStack(spacing: 0) {HStack(spacing: 0) {smallSquare(); smallSquare()}; wideRectangle()}}}
    struct fourPhoto: View {var body: some View {VStack(spacing: 0) {HStack(spacing: 0) {smallSquare(); smallSquare()}.border(Color.black); HStack(spacing: 0)  {smallSquare(); smallSquare()}.border(Color.black)}}}
    
    func loadImage() {
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        image = Image(uiImage: chosenImage)
    }
    
}
