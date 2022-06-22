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
    var searchText: String
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
        let mother = SearchItem(searchTitle: "Mother's Day 🌸", searchTerm: "Flowers")
        menuItems.searchItems.append(birthday)
        menuItems.searchItems.append(mother)
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
                    }.sheet(isPresented: $segueToCollageMenu){
                        let searchObject = SearchParameter.init(searchText: "None")
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
                    }.sheet(isPresented: $segueToCollageMenu){
                        let searchObject = SearchParameter.init(searchText: "None")
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
                    let searchObject = SearchParameter.init(searchText: search.searchTerm)
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
