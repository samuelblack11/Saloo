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

struct CoverImageObject: Identifiable, Hashable {
    let id = UUID()
    let coverImage: Image
    let coverImagePhotographer: String
    let coverImageUserName: String
    let downloadLocation: String
    let index: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(downloadLocation)
    }

}


struct UnsplashCollectionView: View {
    
    var searchParam: SearchParameter
    @State private var imageObjects: [CoverImageObject] = []

    @State private var segueToConfirmFrontCover = false
    @State private var picCount: Int!
    @State private var searchText: String!
    
    @State public var chosenImage: Image!
    @State public var chosenPhotographer: String!
    @State public var chosenUserName: String!
    @State public var chosenDownloadLocation: String!
    @State var chosenObject: CoverImageObject!
    @State var collageImage: CollageImage!
    @State var noteField: NoteField!

    let columns = [GridItem(.fixed(150)),GridItem(.fixed(150))]
    var body: some View {
        NavigationView {
            ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(imageObjects, id: \.self.id) {photoObj in
                    VStack(spacing: 0) {
                        //Text("Hello")
                        photoObj.coverImage
                            .resizable()
                            .frame(width: 125, height: 125)
                }.onTapGesture {
                    handleTap(index: photoObj.index)
                }}}.navigationTitle("Choose Front Cover")
            }
        }
        .font(.headline)
        .padding(.horizontal)
        .frame(maxHeight: 600)
        .onAppear {getUnsplashPhotos()}
        .sheet(isPresented: $segueToConfirmFrontCover) {ConfirmFrontCoverView(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField)}
        }
    
    func handleTap(index: Int) {
        segueToConfirmFrontCover = true
        chosenImage = imageObjects[index].coverImage
        chosenPhotographer = imageObjects[index].coverImagePhotographer
        chosenUserName = imageObjects[index].coverImageUserName
        chosenDownloadLocation = imageObjects[index].downloadLocation
        
        chosenObject = CoverImageObject.init(coverImage: chosenImage, coverImagePhotographer: chosenPhotographer, coverImageUserName: chosenUserName, downloadLocation: chosenDownloadLocation, index: index)
    }

    func getUnsplashPhotos() {
        PhotoAPI.getPhoto(userSearch: searchParam.searchText, completionHandler: { (response, error) in
            if response != nil {
                self.picCount = response!.count
                DispatchQueue.main.async {
                for picture in response! {
                        
                        if picture.urls.small != nil && picture.user.username != nil && picture.user.name != nil && picture.links.download_location != nil {

                            let thisPicture = picture.urls.small
                            let imageURL = URL(string: thisPicture!)
                            let thisPhotoData = try? Data(contentsOf: imageURL!)
                            let image = Image(uiImage: UIImage(data: thisPhotoData!)!)
                            
                            let newObj = CoverImageObject.init(coverImage: image, coverImagePhotographer: picture.user.name!, coverImageUserName: picture.user.username!, downloadLocation: picture.links.download_location!, index: imageObjects.count)
                            imageObjects.append(newObj)
                            print(imageObjects.count)
                    }}}
            if self.picCount == 0 {
                print("No Picture Available for that Search")
                }
            if response == nil {
                print("Response is Nil")
            }}})}
}
