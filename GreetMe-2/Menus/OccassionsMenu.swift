//
//  OccassionsMenu.swift
//  LearningSwiftUI
//
//  Created by Sam Black on 4/28/22.
//
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-a-view-dismiss-itself
import Foundation
import SwiftUI

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
    @State private var image: Image?
    @State var chosenObject: CoverImageObject!
    @State private var segueToCollageMenu = false
    @State var noteField: NoteField!
    @State var collageImage: CollageImage!
    @State var frontCoverIsPersonalPhoto = 0
    @State var pageCount = 1
    @Binding var noneSearch: String!
    
    
    func loadImage() {
        guard let coverImage = coverImage else {return print("loadImage() failed....")}
        image = Image(uiImage: coverImage)
    }
    
    func handlePhotoLibrarySelection() {
        chosenObject = CoverImageObject.init(coverImage: coverImage!, coverImagePhotographer: "", coverImageUserName: "", downloadLocation: "", index: 1)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
      // https://www.hackingwithswift.com/books/ios-swiftui/building-a-list-we-can-delete-from
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
    
    func createOccassionsMenu() {
        let birthday = SearchItem(searchTitle: "Birthday 🎈", searchTerm: "Birthday")
        let superbowl = SearchItem(searchTitle: "Super Bowl 🏟", searchTerm: "Football")
        let valentine = SearchItem(searchTitle: "Valentine's Day ❤️", searchTerm: "Valentine")
        let stpatsday = SearchItem(searchTitle: "St Patrick's Day 🍀", searchTerm: "Clover")
        let mother = SearchItem(searchTitle: "Mother's Day 🌸", searchTerm: "Floral")
        let father = SearchItem(searchTitle: "Father's Day", searchTerm: "Parent")
        let thanksgiving = SearchItem(searchTitle: "Thanksgiving 🍁", searchTerm: "Thanksgiving")
        let hanukkah = SearchItem(searchTitle: "Hanukkah 🕎", searchTerm: "Hanukkah")
        let christmas = SearchItem(searchTitle: "Christmas 🎄", searchTerm: "Christmas")
        let nye = SearchItem(searchTitle: "New Year's 🎇", searchTerm: "Fireworks")

        menuItems.searchItems.append(birthday)
        menuItems.searchItems.append(superbowl)
        menuItems.searchItems.append(valentine)
        menuItems.searchItems.append(stpatsday)
        menuItems.searchItems.append(mother)
        menuItems.searchItems.append(father)
        menuItems.searchItems.append(thanksgiving)
        menuItems.searchItems.append(hanukkah)
        menuItems.searchItems.append(christmas)
        menuItems.searchItems.append(nye)
    }

    var body: some View {
        // NavigationView combines display styling of UINavigationBar and VC stack behavior of UINavigationController.
        // Hold cmd + ctrl, then click space bar to show emoji menu
        NavigationView {
        List {
            Section(header: Text("Personal")) {
                Text("Select from Photo Library ").onTapGesture {
                    showingImagePicker = true
                }
                .sheet(isPresented: $showingImagePicker) { ImagePicker(image: $coverImage)}
                    .navigationTitle("Select Front Cover")
                    .onChange(of: coverImage) { _ in loadImage()
                        handlePhotoLibrarySelection()
                        segueToCollageMenu = true
                        frontCoverIsPersonalPhoto = 1
                        noneSearch = "None"
                    }.sheet(isPresented: $segueToCollageMenu){
                        let searchObject = SearchParameter.init(searchText: $noneSearch)
                        CollageStyleMenu(collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: $chosenObject, noteField: $noteField, searchObject: searchObject)
                    }
                Text("Take Photo with Camera 📸 ")
                }.onTapGesture {
                    showingCameraCapture = true
                }
                .sheet(isPresented: $showingCameraCapture) { CameraCapture(selectedImage: $coverImage, sourceType: .camera)}
                    .onChange(of: coverImage) { _ in loadImage()
                        handlePhotoLibrarySelection()
                        segueToCollageMenu = true
                        frontCoverIsPersonalPhoto = 1
                        noneSearch = "None"

                    }.sheet(isPresented: $segueToCollageMenu){
                        let searchObject = SearchParameter.init(searchText: $noneSearch)
                        CollageStyleMenu(collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: $chosenObject, noteField: $noteField, searchObject: searchObject)
                    }
            Section(header: Text("Occassions & Holidays")) {
            ForEach(menuItems.searchItems, id: \.searchTitle) { search in
                Text(search.searchTitle).onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                    self.searchType = search.searchTerm
                    print(search)
                    print("******")
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: $searchType)
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, pageCount: $pageCount)
                    }
                }
            }
        }
        .navigationTitle("Pick Your Occassion")
        .navigationBarItems(leading:
            Button {
                print("Back button tapped")
                //presentPrior = true
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left").foregroundColor(.blue)
                Text("Back")
            })
        .sheet(isPresented: $presentPrior) {
            MenuView()
        }
        .font(.headline)
        .listStyle(GroupedListStyle())
        }.onAppear(perform: createOccassionsMenu)

    }
}
