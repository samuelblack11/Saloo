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
    @Binding var searchText: String!
}

struct OccassionsMenu: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var presentUCV = false
    @State private var presentPrior = false
    @Binding var searchType: String!
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
    @State var occassion: String!
    @State private var createNew = false
    @State private var showSent = false
    @State private var showReceived = false
    @State private var showCal = false
    @ObservedObject var calViewModel: CalViewModel
    @ObservedObject var showDetailView: ShowDetailView
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    //@EnvironmentObject var sceneDelegate: SceneDelegate
    @State var oo2: Bool

    
    struct SearchItem {
        let searchTitle: String
        let searchTerm: String
      }
    //Class to store array of SearchItem(s)
    class Searches: ObservableObject {
        // @Published ensures change announcements get sent whenever the searchItems array gets modified
        @Published var searchItems = [SearchItem]()
    }
    // @StateObject creates an instance of our Searches class
    // @StateObject asks SwiftUI to watch the object for any change announcements. So any time on of our @Published properties changes the iew will refresh.
    @StateObject var menuItems = Searches()
    
    
    var topBar: some View {
        HStack {
            Spacer()
            Button("Calendar") {
                showCal = true
            }
            .sheet(isPresented: $showCal) {
                MenuView(calViewModel: calViewModel, showDetailView: showDetailView)
                }
        }.frame(width: (UIScreen.screenWidth/1.1), height: (UIScreen.screenHeight/12))
    }
    
    var bottomBar: some View {
        HStack {
            Button{showSent = true} label: {
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
            .sheet(isPresented: $showSent) {ShowPriorCardsView()}
            //.sheet(isPresented: $showReceived) {}
    }
    
    

    var body: some View {
        topBar
        // NavigationView combines display styling of UINavigationBar and VC stack behavior of UINavigationController.
        // Hold cmd + ctrl, then click space bar to show emoji menu
        NavigationView {
        List {
            Section(header: Text("Personal")) {
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
                        let searchObject = SearchParameter.init(searchText: $noneSearch)
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
                        let searchObject = SearchParameter.init(searchText: $noneSearch)
                        CollageStyleMenu(collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: $chosenObject, noteField: $noteField, searchObject: searchObject)
                        }
            }
            Section(header: Text("Occassions & Holidays")) {
            ForEach(menuItems.searchItems, id: \.searchTitle) { search in
                Text(search.searchTitle).onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                    self.searchType = search.searchTerm
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: $searchType)
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, pageCount: $pageCount)
                    }
                
                }
            }
        }
        .sheet(isPresented: $presentPrior) {
            MenuView(calViewModel: calViewModel, showDetailView: showDetailView)
        }
        .sheet(isPresented: $oo2) {
            OpenOwnerShare()
        }
        .onReceive(appDelegate.oo1.$owner) { (x) in
            print(appDelegate.oo1.$owner)
            print("testing.......")
            if x != nil {oo2 = true}
        }
        .font(.headline)
        .listStyle(GroupedListStyle())
        .onAppear(perform: createOccassionsMenu)
        }
        Spacer()
        bottomBar
    }
}








extension OccassionsMenu {
    
    func runIt() {
        print("ownerOpeningOwnShare is TRUE")
    }
    
    func loadImage(pic: UIImage) {
        coverImage = pic
        if showingImagePicker  {
            test_a = true
        }
    }
    
    func handlePhotoLibrarySelection() {
        chosenObject = CoverImageObject.init(coverImage: coverImage?.jpegData(compressionQuality: 1), smallImageURL: URL(string: "https://google.com")!, coverImagePhotographer: "", coverImageUserName: "", downloadLocation: "", index: 1)
        print("created chosenObject")
    }
    
    func handleCameraPic() {
        chosenObject = CoverImageObject.init(coverImage: coverImage?.jpegData(compressionQuality: 1), smallImageURL: URL(string: "https://google.com")!, coverImagePhotographer: "", coverImageUserName: "", downloadLocation: "", index: 1)
        print(segueToCollageMenu)
        print(segueToCollageMenu2)
        print("created chosenObject")
    }
    
    func createOccassionsMenu() {
        let birthday = SearchItem(searchTitle: "Birthday 🎈", searchTerm: "Birthday")
        let valentine = SearchItem(searchTitle: "Valentine's Day ❤️", searchTerm: "Valentine")
        let stpatsday = SearchItem(searchTitle: "St Patrick's Day 🍀", searchTerm: "Clover")
        let mother = SearchItem(searchTitle: "Mother's Day 🌸", searchTerm: "Floral")
        let thanksgiving = SearchItem(searchTitle: "Thanksgiving 🍁", searchTerm: "Thanksgiving")
        let hanukkah = SearchItem(searchTitle: "Hanukkah 🕎", searchTerm: "Hanukkah")
        let christmas = SearchItem(searchTitle: "Christmas 🎄", searchTerm: "Christmas")
        let nye = SearchItem(searchTitle: "New Year's 🎇", searchTerm: "Fireworks")

        menuItems.searchItems.append(birthday)
        menuItems.searchItems.append(valentine)
        menuItems.searchItems.append(stpatsday)
        menuItems.searchItems.append(mother)
        menuItems.searchItems.append(thanksgiving)
        menuItems.searchItems.append(hanukkah)
        menuItems.searchItems.append(christmas)
        menuItems.searchItems.append(nye)
    }
    
    
}
