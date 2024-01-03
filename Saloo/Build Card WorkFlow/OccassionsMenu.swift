//
//  OccassionsMenu.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/28/22.
//

import Foundation
import SwiftUI
import UIKit
import CoreData

struct OccassionsMenu: View {
    // Object to pass to Collage Menu if photo not selcted from UCV
    @EnvironmentObject var chosenOccassion: Occassion
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    @State private var showCameraCapture = false
    @State private var showImagePicker = false
    // Collection Variables. Use @State private for variables owned by this view and not accessible by external views
    //@State private var collections: [CollectionPair] = []
    @State private var yearRoundCollection: [CollectionPair2] = []
    @State private var winterCollection: [CollectionPair2] = []
    @State private var springCollection: [CollectionPair2] = []
    @State private var summerCollection: [CollectionPair2] = []
    @State private var fallCollection: [CollectionPair2] = []
    @EnvironmentObject var appDelegate: AppDelegate
    @ObservedObject var gettingRecord = GettingRecord.shared
    @State var explicitPhotoAlert: Bool = false
    @State private var isImageLoading: Bool = false
    @ObservedObject var apiManager = APIManager.shared
    @State private var isLoadingMenu = false
    @EnvironmentObject var appState: AppState
    @State private var hasShownLaunchView: Bool = true
    @State private var coverImage: UIImage?
    @State private var coverImageFromLibrary: UIImage?
    @State private var coverImageFromCamera: UIImage?
    // 0 or 1 Int used as bool to define whether front cover comes from Unsplash or not
    @State var frontCoverIsPersonalPhoto = 0
    // Variables for text field where user does custom photo search. Initialized as blank String
    @State private var customSearch: String = ""
    @State var loadedImagefromLibraryOrCamera: Bool?
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @ObservedObject var alertVars = AlertVars.shared
    @EnvironmentObject var collectionManager: CollectionManager
    @EnvironmentObject var cardProgress: CardProgress
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    var body: some View {
        // NavigationView combines display styling of UINavigationBar and VC stack behavior of UINavigationController.
        // Hold cmd + ctrl, then click space bar to show emoji menu
        NavigationView {
            VStack {
                CustomNavigationBar(onBackButtonTap: {appState.currentScreen = .buildCard([.photoOptionsView])}, titleContent: .text(chosenObject.frontCoverIsPersonalPhoto == 0 ? "Choose Occasion": "Primary Photo"))
                ProgressBar()
                    .frame(height: 20)
                ZStack {
                    if isLoadingMenu {
                        ProgressView().frame(width: UIScreen.screenWidth/2,height: UIScreen.screenHeight/2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                    }
                    List {
                        if chosenObject.frontCoverIsPersonalPhoto == 1 {
                            Section(header:
                                        VStack(alignment: .leading) {
                                Text("Personal")
                                    .font(.headline)
                            }
                            )
                            {Text("Select from Photo Library ")
                                    .onTapGesture {self.showCameraCapture = false; self.showImagePicker = true}
                                    .fullScreenCover(isPresented: $showImagePicker){ImagePicker(image: $coverImageFromLibrary, explicitPhotoAlert: $explicitPhotoAlert, isImageLoading: $isImageLoading)}
                                    .onChange(of: coverImageFromLibrary) { _ in loadImage(pic: coverImageFromLibrary!)
                                        handlePersonalPhotoSelection()
                                        cardProgress.currentStep = 2
                                        appState.currentScreen = .buildCard([.collageBuilder])
                                        chosenObject.frontCoverIsPersonalPhoto = 1
                                        chosenOccassion.occassion = "None"; chosenOccassion.collectionID = "None"
                                    }
                                Text("Take Photo with Camera 📸 ")
                                    .onTapGesture {
                                        self.showImagePicker = false
                                        self.showCameraCapture = true
                                    }
                                    .fullScreenCover(isPresented: $showCameraCapture)
                                {CameraCapture(image: self.$coverImageFromCamera, isPresented: self.$showCameraCapture, explicitPhotoAlert: $explicitPhotoAlert, sourceType: .camera, isImageLoading: $isImageLoading)}
                                    .onChange(of: coverImageFromCamera) { _ in loadImage(pic: coverImageFromCamera!)
                                        handlePersonalPhotoSelection()
                                        cardProgress.currentStep = 2
                                        appState.currentScreen = .buildCard([.collageBuilder]); chosenObject.frontCoverIsPersonalPhoto = 1
                                        chosenOccassion.occassion = ""; chosenOccassion.collectionID = ""
                                    }
                            }
                        }
                        else {
                            Section(header: Text("Year-Round Occassions")) {
                                menuSection(for: "Birthday 🎈")
                                menuSection(for: "Wedding and Anniversary 💒")
                                menuSection(for: "Baby Shower 🐣")
                                menuSection(for: "Travel ✈️")
                                menuSection(for: "Thinking of You 💭")
                                menuSection(for: "Graduation 🎓")
                            }
                            Section(header: Text("Fall Holidays")) {
                                menuSection(for: "Rosh Hashanah 🔯")
                                menuSection(for: "Halloween 🎃")
                                menuSection(for: "Thanksgiving 🍁")
                            }
                            Section(header: Text("Winter Holidays")) {
                                menuSection(for: "Christmas 🎄")
                                menuSection(for: "Hanukkah 🕎")
                                menuSection(for: "New Years Eve 🎆")
                                menuSection(for: "Valentine’s Day ❤️")
                                menuSection(for: "Mardi Gras 🎭")
                                menuSection(for: "Lunar New Year 🐉")
                            }
                            Section(header: Text("Spring Holidays")) {
                                menuSection(for: "St. Patrick's Day 🍀")
                                menuSection(for: "Easter 🐇")
                                menuSection(for: "Eid al-Fitr ☪️")
                                menuSection(for: "Cinco De Mayo 🇲🇽")
                                menuSection(for: "Mother's Day 🌸")
                                menuSection(for: "Father's Day 🍻")
                            }
                            Section(header: Text("Summer Holidays")) {
                                menuSection(for: "Juneteenth ✊🏿")
                                menuSection(for: "Pride 🏳️‍🌈")
                                menuSection(for: "4th of July 🇺🇸")
                            }
                        }
                    }
                    LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
                }
            }
        .onAppear {
            if networkMonitor.isConnected == false {
                alertVars.alertType = .failedConnection
                alertVars.activateAlert = true
            }
            if apiManager.unsplashAPIKey == "" {
                isLoadingMenu = true
                apiManager.getSecret(keyName: "unsplashAPIKey", forceGetFromAzure: false){keyval in isLoadingMenu = false
                }
            }
        }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
        .font(.headline)
        .listStyle(GroupedListStyle())
        }
    }
}

extension OccassionsMenu {
    
    func menuSection(for collectionTitle: String) -> some View {
        let collection = collectionManager.collections.first(where: { $0.title == collectionTitle })
        
        return Button(action: {
            if let collection = collection, networkMonitor.isConnected {
                frontCoverIsPersonalPhoto = 0
                self.chosenOccassion.occassion = collectionTitle
                self.chosenOccassion.collectionID = collection.id
                appState.currentScreen = .buildCard([.unsplashCollectionView])
            } else if !networkMonitor.isConnected {
                alertVars.alertType = .failedConnection
                alertVars.activateAlert = true
            }
        }) {Text(collectionTitle).font(Font.custom("Papyrus", size: 18)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.primary) }
    }



    
    func loadImage(pic: UIImage) {
        coverImage = pic
        if showImagePicker  {loadedImagefromLibraryOrCamera = true}
    }
    
    func getImageSize() -> (CGSize, Double) {
        var size = CGSize()
        var widthToHeightRatio = Double()
        if let image = UIImage(data: chosenObject.coverImage) {
            let imageSize = image.size
            size = imageSize
        }
        widthToHeightRatio = size.width/size.height
        return (size, widthToHeightRatio)
    }
    
    func handlePersonalPhotoSelection() {
        chosenObject.smallImageURLString = "https://salooapp.com"
        chosenObject.coverImage = coverImage!.jpegData(compressionQuality: 1)!
        chosenObject.coverImagePhotographer = ""
        chosenObject.coverImageUserName = ""
        chosenObject.downloadLocation = ""
        chosenObject.index = 1
        let (size, ratio) = getImageSize()
        chosenObject.coverSizeDetails = "\(size.width),\(size.height),\(ratio)"
    }
}

struct ProgressBar: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var cardProgress: CardProgress
    var steps: [String] {
        return (appDelegate.musicSub.type == .Neither) ? ["🎉", "📸", "📝", "✅"] : ["🎉", "📸", "📝", "🎶", "✅"]
    }

    var actions: [(Int) -> Void] {
        switch appDelegate.musicSub.type {
        case .Neither:
            return [
                { _ in appState.currentScreen = .buildCard([.occasionsMenu]); cardProgress.currentStep = 1 },
                { _ in appState.currentScreen = .buildCard([.collageBuilder]); cardProgress.currentStep = 2 },
                { _ in appState.currentScreen = .buildCard([.writeNoteView]); cardProgress.currentStep = 3 },
                { _ in appState.currentScreen = .buildCard([.finalizeCardView]); cardProgress.currentStep = 4 },
            ]
        default:
            return [
                { _ in appState.currentScreen = .buildCard([.occasionsMenu]); cardProgress.currentStep = 1 },
                { _ in appState.currentScreen = .buildCard([.collageBuilder]); cardProgress.currentStep = 2 },
                { _ in appState.currentScreen = .buildCard([.writeNoteView]); cardProgress.currentStep = 3 },
                { _ in appState.currentScreen = .buildCard([.musicSearchView]); cardProgress.currentStep = 4 },
                { _ in appState.currentScreen = .buildCard([.finalizeCardView]); cardProgress.currentStep = 5 },
            ]
        }
    }

    var body: some View {
        let progress = Double(cardProgress.currentStep) / Double(steps.count)
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule() // Changes Rectangle to Capsule for rounded ends
                    .stroke(lineWidth: 2)
                    .foregroundColor(Color.gray.opacity(0.3)) // Makes the background of the bar transparent with a thin gray border

                Capsule() // Progress filler
                    .frame(width: geometry.size.width * CGFloat(progress))
                    .foregroundColor(Color("SalooTheme"))
                
                HStack(spacing: 0) {
                    ForEach(0..<steps.count) { index in
                        Button(action: {
                            if index <= cardProgress.maxStep {self.actions[index](index)}
                        }) {
                            Text(steps[index])
                        }
                        .frame(width: (geometry.size.width - CGFloat(steps.count * 4)) / CGFloat(steps.count), alignment: .center) // Subtracting the total padding from the available width
                        .padding(.horizontal, 2) // The amount subtracted should be twice the padding amount since there's padding on both sides
                        .disabled(index >= cardProgress.maxStep)
                    }
                }

            }
            .frame(height: 20)
            .onChange(of: cardProgress.currentStep) { newValue in
                if newValue > cardProgress.maxStep {
                    cardProgress.maxStep = newValue
                }
            }
        }
    }

}







