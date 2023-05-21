//
//  UnsplashCollectionView.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/29/22.
//

import Foundation
import SwiftUI

// https://www.hackingwithswift.com/books/ios-swiftui/working-with-identifiable-items-in-swiftui
// https://developer.apple.com/documentation/swiftui/adding-interactivity-with-gestures
// https://www.hackingwithswift.com/books/ios-swiftui/running-code-when-our-app-launches
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-respond-to-view-lifecycle-events-onappear-and-ondisappear
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-fix-initializer-init-rowcontent-requires-that-sometype-conform-to-identifiable

struct UnsplashCollectionView: View {
    // Object for collection selected by user
    @EnvironmentObject var chosenOccassion: Occassion
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    @State private var showOccassions = false
    @State private var showConfirmFrontCover = false
    // Object holding Bools for all views to be displayed.
    // Array of all images displayed in the view
    @State var imageObjects: [CoverImageObject] = []
    // Counts the number of images in the response from Unsplash, as they are added to imageObjects
    @State private var picCount: Int!
    // The image, and it's components, selected by the user
    // Componentes which comprise the chosenObject
    @State public var chosenImage: Data!
    @State public var chosenSmallURL: URL!
    @State public var chosenPhotographer: String!
    @State public var chosenUserName: String!
    @State public var chosenDownloadLocation: String!
    //
    @State private var presentUCV2 = false
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    let columns = [GridItem(.fixed(150)),GridItem(.fixed(150))]
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showFailedConnectionAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(imageObjects, id: \.self.id) {photoObj in
                            AsyncImage(url: photoObj.smallImageURL) { image in
                                image.resizable()} placeholder: {ZStack{Color.gray; ProgressView()}}
                                .frame(width: 125, height: 125)
                                .onTapGesture {Task {
                                    //try? await handleTap(index: photoObj.index)
                                    if networkMonitor.isConnected{try? await handleTap(index: photoObj.index)}
                                    else{showFailedConnectionAlert = true}
                                }}
                        }
                    }
                    .navigationTitle("Choose Front Cover")
                    .navigationBarItems(leading:Button {showOccassions.toggle()} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
                    Button("More...") {
                        if networkMonitor.isConnected {
                            getMorePhotos(); print("page count: \(chosenObject.pageCount)")
                        }
                        else {showFailedConnectionAlert = true}
                        
                    }.disabled(setButtonStatus(imageObjects: imageObjects))
                }
                .modifier(GettingRecordAlert())
                LoadingOverlay()
            }
        }
        
        .font(.headline).padding(.horizontal).frame(maxHeight: 600)
        .onAppear {
            if chosenOccassion.occassion == "None" {
                //getUnsplashPhotos()
                if networkMonitor.isConnected{getUnsplashPhotos()}
                else{showFailedConnectionAlert = true}
            }
            else {
                //getPhotosFromCollection(collectionID: chosenOccassion.collectionID, page_num: chosenObject.pageCount)
                if networkMonitor.isConnected{getPhotosFromCollection(collectionID: chosenOccassion.collectionID, page_num: chosenObject.pageCount)}
                else {showFailedConnectionAlert = true}
            }
        }
        .alert(isPresented: $showFailedConnectionAlert) {
            Alert(title: Text("Network Error"), message: Text("Sorry, we weren't able to connect to the internet. Please reconnect and try again."), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $showConfirmFrontCover) {ConfirmFrontCoverView()}
        .fullScreenCover(isPresented: $showOccassions) {OccassionsMenu()}
        .fullScreenCover(isPresented: $presentUCV2) {UnsplashCollectionView()}
    }
    
}

extension UnsplashCollectionView {

    func setButtonStatus(imageObjects: [CoverImageObject]) -> Bool {
        var disableButton: Bool?
        if imageObjects.count < 30 {disableButton = true}
        else {disableButton = false}
        return disableButton!
    }

    func handleTap(index: Int) async throws {
        print("handle tap has been called....")
            do {
                let imageObjects = self.imageObjects
                let (data1, _) = try await URLSession.shared.data(from: imageObjects[index].smallImageURL)
                chosenObject.smallImageURLString = imageObjects[index].smallImageURL.absoluteString
                chosenObject.coverImage = data1
                chosenObject.coverImagePhotographer = imageObjects[index].coverImagePhotographer
                chosenObject.coverImageUserName = imageObjects[index].coverImageUserName
                chosenObject.downloadLocation = imageObjects[index].downloadLocation
                chosenObject.index = index
                print("Tap Handled....")
                showConfirmFrontCover.toggle()
            }
        catch {debugPrint("Error handling tap .... : \(error)")}
    }
    
    func getPhotosFromCollection(collectionID: String, page_num: Int) {
        PhotoAPI.getPhotosFromCollection(collectionID: collectionID, page_num: page_num, completionHandler: { (response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    for picture in response! {
                        if picture.urls.small != nil && picture.user.username != nil && picture.user.name != nil && picture.links.download_location != nil {
                            let thisPicture = picture.urls.small
                            let imageURL = URL(string: thisPicture!)
                            
                            
                            
                            
                            let newObj = CoverImageObject.init(coverImage: nil, smallImageURL: imageURL!, coverImagePhotographer: picture.user.name!, coverImageUserName: picture.user.username!, downloadLocation: picture.links.download_location!, index: imageObjects.count)
                            imageObjects.append(newObj)
                    }}
                }
            }
            if response != nil {print("No Response!")}
            else {debugPrint(error?.localizedDescription ?? "Error Getting Photos from Collection")}
        })
    }
    
    func getUnsplashPhotos() {
        PhotoAPI.getPhoto(pageNum: chosenObject.pageCount, userSearch: chosenOccassion.collectionID, completionHandler: { (response, error) in
            if response != nil {
                self.picCount = response!.count
                DispatchQueue.main.async {
                    for picture in response! {
                        if picture.urls.small != nil && picture.user.username != nil && picture.user.name != nil && picture.links.download_location != nil {
                            let thisPicture = picture.urls.small
                            let imageURL = URL(string: thisPicture!)
                            let newObj = CoverImageObject.init(coverImage: nil, smallImageURL: imageURL!, coverImagePhotographer: picture.user.name!, coverImageUserName: picture.user.username!, downloadLocation: picture.links.download_location!, index: imageObjects.count)
                            imageObjects.append(newObj)
                    }}
                }
            if self.picCount == 0 {print("No Picture Available for that Search")}
            if response == nil {print("Response is Nil")}
            }
        })
        }
    
    func getMorePhotos() {
        chosenObject.pageCount = chosenObject.pageCount + 1
        presentUCV2 = true
        getUnsplashPhotos()
    }

}
