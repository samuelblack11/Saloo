//
//  UnsplashCollectionView.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/29/22.
//

import Foundation
import SwiftUI

// 

struct UnsplashCollectionView: View {
    // Object for collection selected by user
    @EnvironmentObject var chosenOccassion: Occassion
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    // Object holding Bools for all views to be displayed.
    // Array of all images displayed in the view
    @ObservedObject var imageObjectModel = UCVImageObjectModel()
    // Counts the number of images in the response from Unsplash, as they are added to imageObjects
    @State private var picCount: Int!
    // The image, and it's components, selected by the user
    // Componentes which comprise the chosenObject
    @State public var chosenImage: Data!
    @State public var chosenSmallURL: URL!
    @State public var chosenPhotographer: String!
    @State public var chosenUserName: String!
    @State public var chosenDownloadLocation: String!
    @ObservedObject var gettingRecord = GettingRecord.shared
    @EnvironmentObject var appState: AppState
    let columns = [GridItem(.fixed(150)),GridItem(.fixed(150))]
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @ObservedObject var alertVars = AlertVars.shared
    @State private var hasShownLaunchView: Bool = true
    @EnvironmentObject var cardProgress: CardProgress

    var body: some View {
        NavigationView {
            VStack {
                ProgressBar().frame(height: 20)
                ZStack {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(imageObjectModel.imageObjects, id: \.self.id) {photoObj in
                                AsyncImage(url: photoObj.smallImageURL) { image in
                                    image.resizable()} placeholder: {ZStack{Color.gray; ProgressView()}}
                                    //.frame(width: 125, height: 125)
                                    .frame(width: UIScreen.screenWidth/3, height: UIScreen.screenWidth/3)
                                    .onTapGesture {Task {
                                        //try? await handleTap(index: photoObj.index)
                                        if networkMonitor.isConnected{try? await handleTap(index: photoObj.index)}
                                        else{
                                            alertVars.alertType = .failedConnection
                                            alertVars.activateAlert = true
                                        }
                                    }}
                            }
                        }
                        .navigationTitle("Primary Photo")
                        .navigationBarItems(leading:Button {chosenObject.pageCount = 1; appState.currentScreen = .buildCard([.occasionsMenu])} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
                        if setButtonStatus(imageObjects: imageObjectModel.imageObjects) == false {
                            Button("More...") {
                                if networkMonitor.isConnected {
                                    //imageObjectModel.getMorePhotos(chosenObject: chosenObject); print("page count: \(chosenObject.pageCount)")
                                    chosenObject.pageCount = chosenObject.pageCount + 1
                                    //imageObjectModel.imageObjects = []
                                    imageObjectModel.getPhotosFromCollection(collectionID: chosenOccassion.collectionID, page_num: chosenObject.pageCount)
                                }
                                else {
                                    alertVars.alertType = .failedConnection
                                    alertVars.activateAlert = true
                                    
                                }
                                
                            }//.disabled(setButtonStatus(imageObjects: imageObjectModel.imageObjects))
                        }
                    }
                    .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
                    LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
                }
            }
        }
        
        .font(.headline).padding(.horizontal).frame(maxHeight: 600)
        .onAppear {
                if networkMonitor.isConnected {
                    imageObjectModel.getPhotosFromCollection(collectionID: chosenOccassion.collectionID, page_num: chosenObject.pageCount)
                }
                else {
                    alertVars.alertType = .failedConnection
                    alertVars.activateAlert = true
                }
        }
    }
    
}

extension UnsplashCollectionView {

    func setButtonStatus(imageObjects: [CoverImageObject]) -> Bool {
        var disableButton: Bool?
        if (imageObjects.count * chosenObject.pageCount) < (30 * chosenObject.pageCount) {disableButton = true}
        else {disableButton = false}
        print("---")
        print(imageObjects.count)
        return disableButton!
    }
    
    func getCoverSize() -> (CGSize, Double) {
        var size = CGSize()
        var widthToHeightRatio = Double()
        if let image = UIImage(data: chosenObject.coverImage) {
            let imageSize = image.size
            size = imageSize
        }
        print("Image Size....")
        widthToHeightRatio = size.width/size.height
        print(size)
        print(widthToHeightRatio)
        return (size, widthToHeightRatio)
    }
    

    func handleTap(index: Int) async throws {
        print("handle tap has been called....")
        print(imageObjectModel.imageObjects[index])
            do {
                let imageObjects = imageObjectModel.imageObjects
                let (data1, _) = try await URLSession.shared.data(from: imageObjects[index].smallImageURL)
                chosenObject.smallImageURLString = imageObjects[index].smallImageURL.absoluteString
                chosenObject.coverImage = data1
                chosenObject.coverImagePhotographer = imageObjects[index].coverImagePhotographer
                chosenObject.coverImageUserName = imageObjects[index].coverImageUserName
                chosenObject.downloadLocation = imageObjects[index].downloadLocation
                chosenObject.index = index
                let (size, ratio) = getCoverSize()
                chosenObject.coverSizeDetails = "\(size.width),\(size.height),\(ratio)"
                //chosenObject.imageID = imageObjects[index].
                print("Tap Handled....")
                appState.currentScreen = .buildCard([.confirmFrontCoverView])
            }
        catch {debugPrint("Error handling tap .... : \(error)")}
    }
}
