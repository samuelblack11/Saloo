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
    // Object holding Bools for all views to be displayed.
    @ObservedObject var viewTransitions: ViewTransitions
    // Object for collection selected by user
    @State var chosenCollection: ChosenCollection
    // Array of all images displayed in the view
    @State var imageObjects: [CoverImageObject] = []
    // Counts the number of images in the response from Unsplash, as they are added to imageObjects
    @State private var picCount: Int!
    // Counts the page of the response being viewed by the user. 30 images per page maximum
    @State var pageCount: Int
    // The image, and it's components, selected by the user
    @ObservedObject var chosenObject: ChosenCoverImageObject
    // Componentes which comprise the chosenObject
    @State public var chosenImage: Data!
    @State public var chosenSmallURL: URL!
    @State public var chosenPhotographer: String!
    @State public var chosenUserName: String!
    @State public var chosenDownloadLocation: String!
    //
    @Binding var frontCoverIsPersonalPhoto: Int
    @State private var presentUCV2 = false
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    let columns = [GridItem(.fixed(150)),GridItem(.fixed(150))]
    
    //Variables that are currenly inactive
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(imageObjects, id: \.self.id) {photoObj in
                        AsyncImage(url: photoObj.smallImageURL) { image in
                            image.resizable()} placeholder: {Color.gray}
                            .frame(width: 125, height: 125)
                            .onTapGesture {Task {try? await handleTap(index: photoObj.index)}}
                    }
                }
                .navigationTitle("Choose Front Cover")
                .navigationBarItems(leading:Button {viewTransitions.isShowingOccassions.toggle(); viewTransitions.isShowingUCV.toggle()} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
                Button("More...") {getMorePhotos(); print("page count: \(pageCount)")}.disabled(setButtonStatus(imageObjects: imageObjects))
            }
        }
        .font(.headline).padding(.horizontal).frame(maxHeight: 600)
        .onAppear {
            if chosenCollection.occassion == "None" {getUnsplashPhotos()}
            else {getPhotosFromCollection(collectionID: chosenCollection.collectionID, page_num: pageCount)}
        }
        .fullScreenCover(isPresented: $viewTransitions.isShowingOccassions) {OccassionsMenu(calViewModel: CalViewModel(), showDetailView: ShowDetailView(), viewTransitions: viewTransitions)}
        .fullScreenCover(isPresented: $viewTransitions.isShowingConfirmFrontCover) {ConfirmFrontCoverView(viewTransitions: viewTransitions, chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenCollection: chosenCollection, pageCount: pageCount)}
        //.fullScreenCover(isPresented: $presentUCV2) {UnsplashCollectionView(viewTransitions: viewTransitions, chosenSmallURL: chosenSmallURL, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenCollection: chosenCollection, pageCount: $pageCount)}
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
                viewTransitions.isShowingConfirmFrontCover = true
                viewTransitions.isShowingUCV = false

            }
        catch {debugPrint("Error handling tap .... : \(error)"); viewTransitions.isShowingConfirmFrontCover = true; viewTransitions.isShowingUCV = false}    
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
        PhotoAPI.getPhoto(pageNum: pageCount, userSearch: chosenCollection.collectionID, completionHandler: { (response, error) in
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
        pageCount = pageCount + 1
        presentUCV2 = true
    }

}
