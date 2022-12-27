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
    @ObservedObject var viewTransitions: ViewTransitions
    
    @Environment(\.presentationMode) var presentationMode
    @State var photoCollection: PhotoCollection?
    @State var imageObjects: [CoverImageObject] = []
    @State private var picCount: Int!
    @State private var searchText: String!
    @State public var chosenImage: Data!
    @State public var chosenSmallURL: URL!
    @State public var chosenPhotographer: String!
    @State public var chosenUserName: String!
    @State public var chosenDownloadLocation: String!
    @State var chosenObject: CoverImageObject!
    @State var collageImage: CollageImage!
    @State var noteField: NoteField!
    @State private var presentPrior = false
    @Binding var frontCoverIsPersonalPhoto: Int
    @State private var shouldAnimate = false
    @State private var downloadAmount = 0.0
    @State var searchType: String!
    @State private var presentUCV2 = false
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    let columns = [GridItem(.fixed(150)),GridItem(.fixed(150))]
    @State var chosenCollection: ChosenCollection
    @Binding var pageCount: Int
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(imageObjects, id: \.self.id) {photoObj in
                        AsyncImage(url: photoObj.smallImageURL) { image in
                            image.resizable()} placeholder: {Color.gray}
                            .frame(width: 125, height: 125)
                            .onTapGesture {Task {try? await handleTap(index: photoObj.index)};
                                viewTransitions.isShowingConfirmFrontCover = true
                            }
                    }
                }
                .navigationTitle("Choose Front Cover")
                .navigationBarItems(leading:Button {viewTransitions.isShowingOccassions.toggle(); viewTransitions.isShowingUCV.toggle(); print("----"); print(viewTransitions.isShowingOccassions)} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
                Button("More...") {
                    print("Why is this running now.....")
                    getMorePhotos()
                    print("page count: \(pageCount)")
                }
                .disabled(setButtonStatus(imageObjects: imageObjects))
            }
        }
        .font(.headline)
        .padding(.horizontal)
        .frame(maxHeight: 600)
        .onAppear {
            print("-----")
            print(viewTransitions.isShowingOccassions)
            print(viewTransitions.isShowingUCV)
            
            if chosenCollection.occassion == "None" {getUnsplashPhotos()}
            else {getPhotosFromCollection(collectionID: chosenCollection.collectionID, page_num: pageCount)}
        }
        .fullScreenCover(isPresented: $viewTransitions.isShowingOccassions) {OccassionsMenu(calViewModel: CalViewModel(), showDetailView: ShowDetailView(), viewTransitions: viewTransitions)}
        .fullScreenCover(isPresented: $viewTransitions.isShowingConfirmFrontCover) {ConfirmFrontCoverView(viewTransitions: viewTransitions, chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenCollection: chosenCollection, pageCount: $pageCount)}
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
        viewTransitions.isShowingConfirmFrontCover = true
            do {
                var imageObjects = self.imageObjects
                let (data1, _) = try await URLSession.shared.data(from: imageObjects[index].smallImageURL)
                chosenSmallURL = imageObjects[index].smallImageURL
                chosenPhotographer = imageObjects[index].coverImagePhotographer
                chosenUserName = imageObjects[index].coverImageUserName
                chosenDownloadLocation = imageObjects[index].downloadLocation
                chosenObject = CoverImageObject.init(coverImage: data1, smallImageURL: chosenSmallURL, coverImagePhotographer: chosenPhotographer, coverImageUserName: chosenUserName, downloadLocation: chosenDownloadLocation, index: index)
            }
            catch {
                debugPrint("Error handling tap .... : \(error)")
            }
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
            else {debugPrint(error?.localizedDescription)}
        })
    }
    
    func getUnsplashPhotos() {
        print("@#@#@#@#")
        print(chosenCollection.collectionID)
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
            if self.picCount == 0 {
                print("No Picture Available for that Search")
                }
            if response == nil {
                print("Response is Nil")
            }}})}
    
    func getMorePhotos() {
        pageCount = pageCount + 1
        presentUCV2 = true
    }

}
