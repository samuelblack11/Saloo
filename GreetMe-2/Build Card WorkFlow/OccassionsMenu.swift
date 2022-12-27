//
//  OccassionsMenu.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/28/22.
//
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-a-view-dismiss-itself
// https://www.hackingwithswift.com/books/ios-swiftui/building-a-list-we-can-delete-from
// https://stackoverflow.com/questions/66283978/swiftui-open-a-specific-view-when-user-opens-a-push-notification/66284621#66284621
import Foundation
import SwiftUI
import UIKit
import FSCalendar

struct OccassionsMenu: View {
    //@Environment(\.presentationMode) var presentationMode
    // Collection Variables. Use @State private for variables owned by this view and not accessible by external views
    @State private var collections: [CollectionPair] = []
    @State private var yearRoundCollection: [CollectionPair] = []
    @State private var winterCollection: [CollectionPair] = []
    @State private var springCollection: [CollectionPair] = []
    @State private var summerCollection: [CollectionPair] = []
    @State private var fallCollection: [CollectionPair] = []
    @State private var otherCollection: [CollectionPair] = []
    // Use @ObservedObject for complex properties shared across multiple views
    @ObservedObject var calViewModel: CalViewModel
    @ObservedObject var showDetailView: ShowDetailView
    @ObservedObject var viewTransitions: ViewTransitions
    //Custom Types used to create a Card object
    @State var chosenObject: CoverImageObject!
    @State var noteField: NoteField!
    @State var collageImage: CollageImage!
    // Cover Image Variables used dependent on the image's source
    @State private var coverImage: UIImage?
    @State private var coverImageFromLibrary: UIImage?
    @State private var coverImageFromCamera: UIImage?
    // 0 or 1 Int used as bool to define whether front cover comes from Unsplash or not
    @State var frontCoverIsPersonalPhoto = 0
    // Variables for text field where user does custom photo search. Initialized as blank String
    @State private var customSearch: String = ""
    // Defines page number to be used when displaying photo results on UCV
    @State private var pageCount = 1
    //
    @State var loadedImagefromLibraryOrCamera: Bool?
    @StateObject var occassionInstance = Occassion()
    
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
    var topBar: some View {
        HStack {
            Spacer()
            Button("Calendar") {viewTransitions.isShowingCalendar = true}
            .sheet(isPresented: $viewTransitions.isShowingCalendar ) {CalendarParent(calViewModel: calViewModel, showDetailView: showDetailView)}
        }.frame(width: (UIScreen.screenWidth/1.1), height: (UIScreen.screenHeight/12))
    }
    
    var bottomBar: some View {
        HStack {
            Button{viewTransitions.isShowingSentCards = true} label: {
                Image(systemName: "tray.and.arrow.up.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                }
            Spacer()
            Button{viewTransitions.isShowingReceivedCards = true} label: {
                Image(systemName: "tray.and.arrow.down.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                }
            }
            .padding(.bottom, 30)
            .sheet(isPresented: $viewTransitions.isShowingSentCards) {Outbox()}
            //.sheet(isPresented: $isShowingReceivedCards) {}
    }
    
    

    var body: some View {
        topBar
        // NavigationView combines display styling of UINavigationBar and VC stack behavior of UINavigationController.
        // Hold cmd + ctrl, then click space bar to show emoji menu
        NavigationView {
        List {
            Section(header: Text("Personal & Search")) {
                Text("Select from Photo Library ").onTapGesture {self.viewTransitions.isShowingCameraCapture = false; self.viewTransitions.isShowingImagePicker = true}
                    .sheet(isPresented: $viewTransitions.isShowingImagePicker){ImagePicker(image: $coverImageFromLibrary)}
                    .onChange(of: coverImageFromLibrary) { _ in loadImage(pic: coverImageFromLibrary!)
                        handlePhotoLibrarySelection()
                        viewTransitions.isShowingCollageMenu = true
                        frontCoverIsPersonalPhoto = 1
                        }
                    .sheet(isPresented: $viewTransitions.isShowingCollageMenu){
                        let blankCollection = ChosenCollection.init(occassion: "None", collectionID: "None")
                        CollageStyleMenu(viewTransitions: viewTransitions, collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: $chosenObject, noteField: $noteField, chosenCollection: blankCollection)
                    }
                Text("Take Photo with Camera 📸 ").onTapGesture {
                    self.viewTransitions.isShowingImagePicker = false
                    self.viewTransitions.isShowingCameraCapture = true
                }
                .sheet(isPresented: $viewTransitions.isShowingCameraCapture)
                {CameraCapture(image: self.$coverImageFromCamera, isPresented: self.$viewTransitions.isShowingCameraCapture, sourceType: .camera)}
                .onChange(of: coverImageFromCamera) { _ in loadImage(pic: coverImageFromCamera!)
                        handleCameraPic()
                    viewTransitions.isShowingCollageMenu = true
                        frontCoverIsPersonalPhoto = 1
                    }
                .sheet(isPresented: $viewTransitions.isShowingCollageMenu){
                    let blankCollection = ChosenCollection.init(occassion: "None", collectionID: "None")
                    CollageStyleMenu(viewTransitions: viewTransitions, collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: $chosenObject, noteField: $noteField, chosenCollection: blankCollection)}
                HStack {
                    TextField("Custom Search", text: $customSearch)
                        .padding(.leading, 5)
                        .frame(height:35)
                    Button {viewTransitions.isShowingUCV = true; frontCoverIsPersonalPhoto = 0
                        self.occassionInstance.occassion = "None"
                        self.occassionInstance.collectionID = customSearch
                    }
                    label: {Image(systemName: "magnifyingglass.circle.fill")}
                        .sheet(isPresented: $viewTransitions.isShowingUCV) {
                        let chosenCollection = ChosenCollection.init(occassion: occassionInstance.occassion, collectionID: occassionInstance.collectionID)
                            UnsplashCollectionView(viewTransitions: viewTransitions, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenCollection: chosenCollection, pageCount: $pageCount)
                    }
                }
            }
            Section(header: Text("Year-Round Occassions")) {ForEach(yearRoundCollection) {menuSection(for: $0, shareable: false)}}
            Section(header: Text("Winter Holidays")) {ForEach(winterCollection) {menuSection(for: $0, shareable: false)}}
            Section(header: Text("Spring Holidays")) {ForEach(springCollection) {menuSection(for: $0, shareable: false)}}
            Section(header: Text("Summer Holidays")) {ForEach(summerCollection) {menuSection(for: $0, shareable: false)}}
            Section(header: Text("Fall Holidays")) {ForEach(fallCollection) {menuSection(for: $0, shareable: false)}}
            Section(header: Text("Other Collections")) {ForEach(otherCollection) {menuSection(for: $0, shareable: false)}}
        }
        .sheet(isPresented: $viewTransitions.isShowingCalendar) {CalendarParent(calViewModel: calViewModel, showDetailView: showDetailView)}
        .font(.headline)
        .listStyle(GroupedListStyle())
        .onAppear {createOccassionsFromUserCollections()}
        }
        Spacer()
        bottomBar
    }
}

extension OccassionsMenu {
    
    private func menuSection(for collection: CollectionPair, shareable: Bool = true) -> some View {
            Text(collection.title).onTapGesture {
                viewTransitions.isShowingUCV = true
                frontCoverIsPersonalPhoto = 0
                self.occassionInstance.occassion = collection.title
                self.occassionInstance.collectionID = collection.id
            }.sheet(isPresented: $viewTransitions.isShowingUCV) {
                let chosenCollection = ChosenCollection.init(occassion: occassionInstance.occassion, collectionID: occassionInstance.collectionID)
                UnsplashCollectionView(viewTransitions: viewTransitions, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenCollection: chosenCollection, pageCount: $pageCount)
                }
    }
    
    func groupCollections(collections: [CollectionPair]) {
        let yearRoundOccassions = ["Birthday 🎈", "Postcard ✈️", "Anniversary 💒", "Graduation 🎓"]
        let winterOccassions = ["Christmas 🎄", "Hanukkah 🕎", "New Years Eve 🎆"]
        let springOccassions = ["Mother's Day 🌸"]
        let summerOccassions = ["4th of July 🎇", "Father's Day 🍻"]
        let fallOccassions = ["Thanksgiving 🍁","Rosh Hashanah 🔯"]
        let otherOccassions = ["Animals 🐼"]
        
        for collection in collections {
            if yearRoundOccassions.contains(collection.title) {yearRoundCollection.append(collection)}
            if winterOccassions.contains(collection.title) {winterCollection.append(collection)}
            if springOccassions.contains(collection.title) {springCollection.append(collection)}
            if summerOccassions.contains(collection.title) {summerCollection.append(collection)}
            if fallOccassions.contains(collection.title) {fallCollection.append(collection)}
            if otherOccassions.contains(collection.title) {otherCollection.append(collection)}
        }
    }
    
    func createOccassionsFromUserCollections() {
            PhotoAPI.getUserCollections(username: "samuelblack11", completionHandler: { (response, error) in
                if response != nil {
                    DispatchQueue.main.async {
                        for collection in response! {collections.append(CollectionPair(title: collection.title, id: collection.id))
                            }
                        groupCollections(collections: collections)
                    }
                }
                if response != nil {print("No Response!")}
                else {debugPrint(error?.localizedDescription)}
            })
    }
    
    func loadImage(pic: UIImage) {
        coverImage = pic
        if viewTransitions.isShowingImagePicker  {loadedImagefromLibraryOrCamera = true}
    }
    
    func handlePhotoLibrarySelection() {
        chosenObject = CoverImageObject.init(coverImage: coverImage?.jpegData(compressionQuality: 1), smallImageURL: URL(string: "https://google.com")!, coverImagePhotographer: "", coverImageUserName: "", downloadLocation: "", index: 1)
    }
    
    func handleCameraPic() {
        chosenObject = CoverImageObject.init(coverImage: coverImage?.jpegData(compressionQuality: 1), smallImageURL: URL(string: "https://google.com")!, coverImagePhotographer: "", coverImageUserName: "", downloadLocation: "", index: 1)
    }
    
}
