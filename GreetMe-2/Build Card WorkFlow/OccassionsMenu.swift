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

struct SearchParameter {
    @State var searchText: String!
}

struct ChosenCollection {
    @State var occassion: String!
    @State var collectionID: String!
}

struct OccassionsMenu: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var presentUCV = false
    @State private var presentPrior = false
    @StateObject var cm = CKModel()

    @State var searchObject: SearchParameter!
    @State private var showingImagePicker = false
    @State private var showingCameraCapture = false
    @State private var coverImage: UIImage?
    @State private var coverImageFromLibrary: UIImage?
    @State private var coverImageFromCamera: UIImage?
    @State private var image: Image?
    @State var chosenObject: CoverImageObject!
    @State private var segueToCollageMenu = false
    @State private var segueToCollageMenu2 = false
    @State var noteField: NoteField!
    @State var collageImage: CollageImage!
    @State var frontCoverIsPersonalPhoto = 0
    @State var pageCount = 1
    @State var test_a: Bool = false
    @Binding var noneSearch: String!
    @Binding var searchTerm: String!
    @State private var createNew = false
    @State private var showSent = false
    @State private var showReceived = false
    @State private var showCal = false
    @ObservedObject var calViewModel: CalViewModel
    @ObservedObject var showDetailView: ShowDetailView
    //@UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    //@EnvironmentObject var sceneDelegate: SceneDelegate
    @State var oo2: Bool
    @State private var customSearch: String = ""

    @State var collections: [CollectionPair] = []
    //@State var chosenCollection: CollectionPair?
    // @StateObject creates an instance of our Searches class
    // @StateObject asks SwiftUI to watch the object for any change announcements. So any time on of our @Published properties changes the iew will refresh.
    @StateObject var menuItems = Searches()
    
    @State var yearRoundCollection: [CollectionPair] = []
    @State var winterCollection: [CollectionPair] = []
    @State var springCollection: [CollectionPair] = []
    @State var summerCollection: [CollectionPair] = []
    @State var fallCollection: [CollectionPair] = []
    @State var otherCollection: [CollectionPair] = []

    
    
    //Class to store array of SearchItem(s)
    class Searches: ObservableObject {
        // @Published ensures change announcements get sent whenever the searchItems array gets modified
        @Published var searchItems = [SearchItem]()
    }
    struct SearchItem {
        let searchTitle: String
        let searchTerm: String
      }
    
    @StateObject var occassionInstance = Occassion()
    class Occassion: ObservableObject {
        //@Published var searchType = String()
        @Published var occassion = String()
        @Published var collectionID = String()
    }
    
    
    
        
    var topBar: some View {
        HStack {
            Spacer()
            Button("Calendar") {
                showCal = true
            }
            .sheet(isPresented: $showCal) {
                CalendarParent(calViewModel: calViewModel, showDetailView: showDetailView)
                }
        }.frame(width: (UIScreen.screenWidth/1.1), height: (UIScreen.screenHeight/12))
    }
    
    var bottomBar: some View {
        HStack {
            Button{
                showSent = true
                
            } label: {
                Image(systemName: "tray.and.arrow.up.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                }
            Spacer()
            Button{showReceived = true} label: {
                Image(systemName: "tray.and.arrow.down.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                }
            }
            .padding(.bottom, 30)
            .sheet(isPresented: $showSent) {Outbox()}
            //.sheet(isPresented: $showReceived) {}
    }
    
    

    var body: some View {
        topBar
        // NavigationView combines display styling of UINavigationBar and VC stack behavior of UINavigationController.
        // Hold cmd + ctrl, then click space bar to show emoji menu
        NavigationView {
        List {
            Section(header: Text("Personal & Search")) {
                Text("Select from Photo Library ").onTapGesture {
                    self.showingCameraCapture = false
                    self.showingImagePicker = true
                }
                    .sheet(isPresented: $showingImagePicker)
                        {ImagePicker(image: $coverImageFromLibrary)}
                //.navigationTitle("Select Front Cover")
                    .onChange(of: coverImageFromLibrary) { _ in loadImage(pic: coverImageFromLibrary!)
                        handlePhotoLibrarySelection()
                        segueToCollageMenu = true
                        frontCoverIsPersonalPhoto = 1
                        noneSearch = "None"
                        }
                    .sheet(isPresented: $segueToCollageMenu){
                        let searchObject = SearchParameter.init(searchText: noneSearch)
                        CollageStyleMenu(collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: $chosenObject, noteField: $noteField, searchObject: searchObject)
                    }
                Text("Take Photo with Camera 📸 ").onTapGesture {
                    self.showingImagePicker = false
                    self.showingCameraCapture = true
                }
                .sheet(isPresented: $showingCameraCapture)
                {CameraCapture(image: self.$coverImageFromCamera, isPresented: self.$showingCameraCapture, sourceType: .camera)}
                .onChange(of: coverImageFromCamera) { _ in loadImage(pic: coverImageFromCamera!)
                        handleCameraPic()
                        segueToCollageMenu2 = true
                        frontCoverIsPersonalPhoto = 1
                        noneSearch = "None"
                    }
                .sheet(isPresented: $segueToCollageMenu2){
                        let searchObject = SearchParameter.init(searchText: noneSearch)
                        CollageStyleMenu(collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: $chosenObject, noteField: $noteField, searchObject: searchObject)
                        }
                HStack {
                    TextField("Custom Search", text: $customSearch)
                        .padding(.leading, 5)
                        .frame(height:35)
                    Button {
                        presentUCV = true
                        frontCoverIsPersonalPhoto = 0
                        self.searchTerm = customSearch
                    }
                    label: {Image(systemName: "magnifyingglass.circle.fill")}
                    .sheet(isPresented: $presentUCV) {let searchObject = SearchParameter.init(searchText: searchTerm)
                        UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, pageCount: $pageCount)}
                
                }
            }
            Section(header: Text("Year-Round Occassions")) {
                ForEach(yearRoundCollection) {menuSection(for: $0, shareable: false)}
            }
            Section(header: Text("Winter Holidays")) {
                ForEach(winterCollection) {menuSection(for: $0, shareable: false)}
            }
            Section(header: Text("Spring Holidays")) {
                ForEach(springCollection) {menuSection(for: $0, shareable: false)}
            }
            Section(header: Text("Summer Holidays")) {
                ForEach(summerCollection) {menuSection(for: $0, shareable: false)}
            }
            Section(header: Text("Fall Holidays")) {
                ForEach(fallCollection) {menuSection(for: $0, shareable: false)}
            }
            Section(header: Text("Other Collections")) {
                ForEach(otherCollection) {menuSection(for: $0, shareable: false)}
            }
            Section(header: Text("Custom Search")) {

            }
            
        }
        .sheet(isPresented: $presentPrior) {
            CalendarParent(calViewModel: calViewModel, showDetailView: showDetailView)
        }
        .font(.headline)
        .listStyle(GroupedListStyle())
        .onAppear {
            createOccassionsFromUserCollections()
        }

        }
        Spacer()
        bottomBar
    }
}









extension OccassionsMenu {
    
    private func menuSection(for collection: CollectionPair, shareable: Bool = true) -> some View {
        //ForEach(collections, id: \.title) { collection in
            Text(collection.title).onTapGesture {
                presentUCV = true
                frontCoverIsPersonalPhoto = 0
                self.occassionInstance.occassion = collection.title
                self.occassionInstance.collectionID = collection.id
            }.sheet(isPresented: $presentUCV) {
                let chosenCollection = ChosenCollection.init(occassion: occassionInstance.occassion, collectionID: occassionInstance.collectionID)
                let searchObject = SearchParameter.init(searchText: occassionInstance.collectionID)
                UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenCollection: chosenCollection, pageCount: $pageCount)
                }
        //}
    }
    
    func groupCollections(collections: [CollectionPair]) {
        print("called groupCollections.....")
        let yearRoundOccassions = ["Birthday 🎈", "Postcard ✈️", "Anniversery 💒", "Graduation 🎓"]
        let winterOccassions = ["Christmas 🎄", "Hanukkah 🕎", "New Year's Eve 🎆"]
        let springOccassions = ["Mother's Day 🌸"]
        let summerOccassions = ["4th of July 🎇", "Father's Day 🍻"]
        let fallOccassions = ["Thanksgiving 🍁","Rosh Hashanah 🔯"]
        let otherOccassions = ["Animals 🐼"]
        
        for collection in collections {
            if yearRoundOccassions.contains(collection.title) {
                yearRoundCollection.append(collection)
            }
            if winterOccassions.contains(collection.title) {
                winterCollection.append(collection)
            }
            if springOccassions.contains(collection.title) {
                springCollection.append(collection)
            }
            if summerOccassions.contains(collection.title) {
                summerCollection.append(collection)
            }
            if fallOccassions.contains(collection.title) {
                fallCollection.append(collection)
            }
            if otherOccassions.contains(collection.title) {
                otherCollection.append(collection)
            }
            
        }
    }
    
    func createOccassionsFromUserCollections() {
            PhotoAPI.getUserCollections(username: "samuelblack11", completionHandler: { (response, error) in
                if response != nil {
                    DispatchQueue.main.async {
                        for collection in response! {collections.append(CollectionPair(title: collection.title, id: collection.id))
                            
                        }
                        print("%%%")
                        groupCollections(collections: collections)
                        print("+++")
                        print(yearRoundCollection)
                        
                    }
                    print("====")
                    print(collections)
                }
                if response != nil {print("No Response!")}
                else {debugPrint(error?.localizedDescription)}
                print("---")
                print(collections)
            })
            print("@@@")
            print(collections)

    }
    
    func loadImage(pic: UIImage) {
        coverImage = pic
        if showingImagePicker  {
            test_a = true
        }
    }
    
    func handlePhotoLibrarySelection() {
        chosenObject = CoverImageObject.init(coverImage: coverImage?.jpegData(compressionQuality: 1), smallImageURL: URL(string: "https://google.com")!, coverImagePhotographer: "", coverImageUserName: "", downloadLocation: "", index: 1)
    }
    
    func handleCameraPic() {
        chosenObject = CoverImageObject.init(coverImage: coverImage?.jpegData(compressionQuality: 1), smallImageURL: URL(string: "https://google.com")!, coverImagePhotographer: "", coverImageUserName: "", downloadLocation: "", index: 1)
    }
    
}
