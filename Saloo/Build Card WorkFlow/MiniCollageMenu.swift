//
//  CollageStyleMenu.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/28/22.
//
// 

import Foundation
import SwiftUI

struct MiniCollageMenu: View {
    // The image, and it's components, selected by the user
    // Object for collection selected by user
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    @EnvironmentObject var chosenOccassion: Occassion
    @EnvironmentObject var collageImage: CollageImage
    @State private var showImagePicker = false
    @State private var transitionVariable = false
    @EnvironmentObject var appDelegate: AppDelegate
    // Is front cover a personal photo? (selected from camera or library)
    // Tracks which collage type (#) was selected by the user
    @State private var collageStyles = []
    @State private var collageBlocks = CollageBlocksAndViews()
    @ObservedObject var gettingRecord = GettingRecord.shared
    @ObservedObject var alertVars = AlertVars.shared
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    @EnvironmentObject var appState: AppState
    @State private var hasShownLaunchView: Bool = true
    @State private var selectedStyle: Int? = nil
    var miniWidth = UIScreen.screenWidth/4
    var miniHeight = UIScreen.screenHeight/8
    var body: some View {
                VStack {
                    HStack {
                        collageBlocks.onePhotoView(block: collageBlocks.blockForStyle())
                            .frame(width: miniWidth, height: miniHeight)
                            .bordered(style: 1, selectedStyle: $selectedStyle)
                            .onTapGesture{collageImage.chosenStyle = 1; selectedStyle = 1}
                        collageBlocks.twoPhotoWide(block: collageBlocks.blockForStyle())
                            .frame(width: miniWidth, height: miniHeight)
                            .bordered(style: 2, selectedStyle: $selectedStyle)
                            .onTapGesture{collageImage.chosenStyle = 2; selectedStyle = 2}
                    }
                    HStack {
                        collageBlocks.twoPhotoLong(block: collageBlocks.blockForStyle())
                            .frame(width: miniWidth, height: miniHeight)
                            .bordered(style: 3, selectedStyle: $selectedStyle)
                            .onTapGesture{collageImage.chosenStyle = 3; selectedStyle = 3}
                        collageBlocks.twoShortOneLong(block: collageBlocks.blockForStyle())
                            .frame(width: miniWidth, height: miniHeight)
                            .bordered(style: 4, selectedStyle: $selectedStyle)
                            .onTapGesture{collageImage.chosenStyle = 4; selectedStyle = 4}
                    }
                    HStack {
                        collageBlocks.twoNarrowOneWide(block: collageBlocks.blockForStyle())
                            .frame(width: miniWidth, height: miniHeight)
                            .bordered(style: 5, selectedStyle: $selectedStyle)
                            .onTapGesture{collageImage.chosenStyle = 5; selectedStyle = 5}
                        collageBlocks.fourPhoto(block: collageBlocks.blockForStyle())
                            .frame(width: miniWidth, height: miniHeight)
                            .bordered(style: 6, selectedStyle: $selectedStyle)
                            .onTapGesture{collageImage.chosenStyle = 6; selectedStyle = 6}
                    }
                }
            .environmentObject(collageImage)
    }
}

extension View {
    func bordered(style: Int, selectedStyle: Binding<Int?>, color: Color = Color("SalooTheme"), width: CGFloat = 5) -> some View {
        self.modifier(BorderedStyleModifier(style: style, selectedStyle: selectedStyle, color: color, width: width))
    }
}

struct BorderedStyleModifier: ViewModifier {
    let style: Int
    @Binding var selectedStyle: Int?
    let color: Color
    let width: CGFloat
    
    func body(content: Content) -> some View {
        Group {
            if style == selectedStyle {
                content
                    .border(color, width: width)
                    .overlay(Text("\(style)").foregroundColor(.white).font(.title), alignment: .center)
            } else {
                content
            }
        }
    }
}


