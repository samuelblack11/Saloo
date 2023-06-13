//
//  CollageStyleMenu.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/28/22.
//
// 

import Foundation
import SwiftUI

struct CollageStyleMenu: View {
    // The image, and it's components, selected by the user
    // Object for collection selected by user
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    @EnvironmentObject var chosenOccassion: Occassion
    @StateObject var collageImage = CollageImage()
    @State private var showImagePicker = false
    @State private var transitionVariable = false
    // Is front cover a personal photo? (selected from camera or library)
    // Tracks which collage type (#) was selected by the user
    @State private var collageStyles = []
    @State private var collageBlocks = CollageBlocksAndViews()
    @ObservedObject var gettingRecord = GettingRecord.shared
    @ObservedObject var alertVars = AlertVars.shared
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        collageBlocks.onePhotoView(block: collageBlocks.blockForStyle()).onTapGesture{collageImage.chosenStyle = 1
                            appState.currentScreen = .buildCard([.collageBuilder])}
                        collageBlocks.twoPhotoWide(block: collageBlocks.blockForStyle()).onTapGesture{collageImage.chosenStyle = 2
                            appState.currentScreen = .buildCard([.collageBuilder])}
                    }
                    HStack {
                        collageBlocks.twoPhotoLong(block: collageBlocks.blockForStyle()).onTapGesture{collageImage.chosenStyle = 3
                            appState.currentScreen = .buildCard([.collageBuilder])}
                        collageBlocks.twoShortOneLong(block: collageBlocks.blockForStyle()).onTapGesture{collageImage.chosenStyle = 4
                            appState.currentScreen = .buildCard([.collageBuilder])}
                    }
                    HStack {
                        collageBlocks.twoNarrowOneWide(block: collageBlocks.blockForStyle()).onTapGesture{collageImage.chosenStyle = 5
                            appState.currentScreen = .buildCard([.collageBuilder])}
                        collageBlocks.fourPhoto(block: collageBlocks.blockForStyle()).onTapGesture{collageImage.chosenStyle = 6; appState.currentScreen = .buildCard([.collageBuilder])}
                    }
                }
                LoadingOverlay()
            }
            .navigationTitle("Pick Collage Style").font(.headline).padding(.horizontal)
            .navigationBarItems(leading:Button {appState.currentScreen = .buildCard([.confirmFrontCoverView])} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
        }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
        .environmentObject(collageImage)
    }
}
