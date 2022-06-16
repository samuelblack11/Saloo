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
    @State var searchType: String!
    @State var searchObject: SearchParameter!
    @State private var showingImagePicker = false
    @State private var coverImage: UIImage?
    @State private var image: Image?
    @State var chosenObject: CoverImageObject!
    @State private var segueToCollageMenu = false
    @State var noteField: NoteField!
    @State var collageImage: CollageImage!
    @State var frontCoverIsPersonalPhoto = 0


    func loadImage() {
        guard let coverImage = coverImage else {return print("loadImage() failed....")}
        image = Image(uiImage: coverImage)
    }
    
    func handlePhotoLibrarySelection() {
        chosenObject = CoverImageObject.init(coverImage: coverImage!, coverImagePhotographer: "", coverImageUserName: "", downloadLocation: "", index: 1)
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
                Text("Birthday 🎈").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Birthday")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Thank You 🙏🏽")
                Text("Sympathy")
                Text("Get Well")
                Text("Just Because 💭")
            }
            Section(header: Text("Life Events")) {
                Text("Graduation")
                Text("Promotion")
                Text("Good Luck")
                Text("Engagement")
                Text("Wedding")
                Text("Baby Shower")
                Text("Anniversery")
                Text("Retirement")
            }
            Section(header: Text("Spring")) {
                Text("Ramadan")
                Text("Passover")
                Text("Good Friday")
                Text("Easter 🐇")
                Text("Kentucky Derby 🐎")
                Text("Cinco De Mayo ")
                Text("Mother's Day 🌸").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Floral")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Memorial Day 🎗")
            }
            Section(header: Text("Summer")) {
                Text("Juneteenth")
                Text("Father's Day 🧔‍♂️")
                Text("Independence Day 🎆")
            }
            Section(header: Text("Fall")) {
                Text("Labor Day")
                Text("Tailgate 🏈")
                Text("Veteran's Day 🇺🇸")
                Text("Rosh Hashana ✡️")
                Text("Yom Kippur")
                Text("Halloween 🎃")
                Text("Thanksgiving 🦃")
                Text("Apple Picking 🍎")
            }
            Section(header: Text("Winter")) {
                Text("New Year's Day")
                Text("Martin Luther King Jr. Day")
                Text("Super Bowl Sunday 🏟")
                Text("Mardi Gras")
                Text("Purim")
                Text("St. Patrick's Day 🍀")
                Text("Kwanzaa")
                Text("Christmas 🎄")
                Text("Hanukkah 🕎")
                Text("New Year's Eve")
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
        }
    }
}
