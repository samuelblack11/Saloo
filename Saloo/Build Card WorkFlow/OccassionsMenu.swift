//
//  OccassionsMenu.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/28/22.
//

import Foundation
import SwiftUI
import UIKit
import FSCalendar
import CoreData

struct OccassionsMenu: View {
    // Object to pass to Collage Menu if photo not selcted from UCV
    @EnvironmentObject var chosenOccassion: Occassion
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    
    //@State private var showSentCards = false
    //@State private var showReceivedCards = false
    @State private var showGridOfCards = false
    @State private var showCameraCapture = false
    @State private var showImagePicker = false
    @State private var showUCV = false
    // Collection Variables. Use @State private for variables owned by this view and not accessible by external views
    @State private var collections: [CollectionPair] = []
    @State private var yearRoundCollection: [CollectionPair] = []
    @State private var winterCollection: [CollectionPair] = []
    @State private var springCollection: [CollectionPair] = []
    @State private var summerCollection: [CollectionPair] = []
    @State private var fallCollection: [CollectionPair] = []
    @State private var otherCollection: [CollectionPair] = []
    @EnvironmentObject var appDelegate: AppDelegate
    @ObservedObject var gettingRecord = GettingRecord.shared
    @State var explicitPhotoAlert: Bool = false
    @State private var isImageLoading: Bool = false
    @ObservedObject var apiManager = APIManager.shared
    @State private var isLoadingMenu = false
    @EnvironmentObject var appState: AppState

    
    // Cover Image Variables used dependent on the image's source
    @State private var coverImage: UIImage?
    @State private var coverImageFromLibrary: UIImage?
    @State private var coverImageFromCamera: UIImage?
    // 0 or 1 Int used as bool to define whether front cover comes from Unsplash or not
    @State var frontCoverIsPersonalPhoto = 0
    // Variables for text field where user does custom photo search. Initialized as blank String
    @State private var customSearch: String = ""
    // Defines page number to be used when displaying photo results on UCV
    @State var loadedImagefromLibraryOrCamera: Bool?
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @ObservedObject var alertVars = AlertVars.shared
    @EnvironmentObject var collectionManager: CollectionManager

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    var body: some View {
        // NavigationView combines display styling of UINavigationBar and VC stack behavior of UINavigationController.
        // Hold cmd + ctrl, then click space bar to show emoji menu
        NavigationView {
            ZStack {
                if isLoadingMenu {
                    ProgressView().frame(width: UIScreen.screenWidth/2,height: UIScreen.screenHeight/2)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                }
                    List {
                        Section(header: Text("Personal & Search")) {
                            Text("Select from Photo Library ")
                            //.listRowBackground(appDelegate.appColor)
                                .onTapGesture {self.showCameraCapture = false; self.showImagePicker = true}
                                .fullScreenCover(isPresented: $showImagePicker){ImagePicker(image: $coverImageFromLibrary, explicitPhotoAlert: $explicitPhotoAlert, isImageLoading: $isImageLoading)}
                                .onChange(of: coverImageFromLibrary) { _ in loadImage(pic: coverImageFromLibrary!)
                                    handlePersonalPhotoSelection()
                                    appState.currentScreen = .buildCard([.collageStyleMenu])
                                    chosenObject.frontCoverIsPersonalPhoto = 1
                                    chosenOccassion.occassion = "None"; chosenOccassion.collectionID = "None"
                                }
                            Text("Take Photo with Camera 📸 ")
                            //.listRowBackground(appDelegate.appColor)
                                .onTapGesture {
                                    self.showImagePicker = false
                                    self.showCameraCapture = true
                                }
                                .fullScreenCover(isPresented: $showCameraCapture)
                            {CameraCapture(image: self.$coverImageFromCamera, isPresented: self.$showCameraCapture, explicitPhotoAlert: $explicitPhotoAlert, sourceType: .camera, isImageLoading: $isImageLoading)}
                                .onChange(of: coverImageFromCamera) { _ in loadImage(pic: coverImageFromCamera!)
                                    handlePersonalPhotoSelection()
                                    appState.currentScreen = .buildCard([.collageStyleMenu]); chosenObject.frontCoverIsPersonalPhoto = 1
                                    chosenOccassion.occassion = ""; chosenOccassion.collectionID = ""
                                }
                        }
                        
                        collectionSection(type: .yearRound, collections: collectionManager.yearRoundCollections)
                        collectionSection(type: .winter, collections: collectionManager.winterCollections)
                        collectionSection(type: .spring, collections: collectionManager.springCollections)
                        collectionSection(type: .summer, collections: collectionManager.summerCollections)
                        collectionSection(type: .fall, collections: collectionManager.fallCollections)
                        collectionSection(type: .other, collections: collectionManager.otherCollections)
                    }
                    LoadingOverlay()
            }
        .onAppear {
            if networkMonitor.isConnected == false {
                alertVars.alertType = .failedConnection
                alertVars.activateAlert = true
            }
            if apiManager.unsplashAPIKey == "" {
                isLoadingMenu = true
                apiManager.getSecret(keyName: "unsplashAPIKey"){keyval in print("UnsplashAPIKey is \(String(describing: keyval))")
                    isLoadingMenu = false
                }
            }
        }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))

        .alert(isPresented: $explicitPhotoAlert) {
            Alert(title: Text("Error"), message: Text("The selected image contains explicit content and cannot be used."), dismissButton: .default(Text("OK")))
        }
        .navigationBarItems(leading:Button {appState.currentScreen = .startMenu} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
        .font(.headline)
        .listStyle(GroupedListStyle())
        }
    }
}

extension OccassionsMenu {
    
    
    func collectionSection(type: CollectionManager.CollectionType, collections: [CollectionPair]) -> some View {
         Section(header: Text(type.rawValue)) {
             ForEach(collections, id: \.id) { collection in
                 self.menuSection(for: collection, shareable: false)
             }
         }
     }


    
    func menuSection(for collection: CollectionPair, shareable: Bool) -> some View {
        Text(collection.title)
            .onTapGesture {
                if networkMonitor.isConnected {
                    frontCoverIsPersonalPhoto = 0
                    chosenOccassion.occassion = collection.title
                    chosenOccassion.collectionID = collection.id
                    appState.currentScreen = .buildCard([.unsplashCollectionView])
                } else {
                    alertVars.alertType = .failedConnection
                    alertVars.activateAlert = true
                }
            }
    }
    
    func loadImage(pic: UIImage) {
        coverImage = pic
        if showImagePicker  {loadedImagefromLibraryOrCamera = true}
    }
    
    func handlePersonalPhotoSelection() {
        chosenObject.smallImageURLString = "https://google.com"
        chosenObject.coverImage = coverImage!.jpegData(compressionQuality: 1)!
        chosenObject.coverImagePhotographer = ""
        chosenObject.coverImageUserName = ""
        chosenObject.downloadLocation = ""
        chosenObject.index = 1
    }

}
