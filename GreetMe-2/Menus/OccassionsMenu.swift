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
    //@State var searchType: String!
    @State var searchObject: SearchParameter!
    @State private var showingImagePicker = false
    @State private var coverImage: UIImage?
    @State private var image: Image?
    @State var chosenObject: CoverImageObject!
    @State private var segueToCollageMenu = false
    @State var noteField: NoteField!
    @State var collageImage: CollageImage!
    @State var frontCoverIsPersonalPhoto = 0
    
    struct search: Identifiable {
        var id: ObjectIdentifier
        var searchType: String
    }
    
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
                Text("Take Photo with Camera 📸 ")
                
                Text("Birthday 🎈").onTapGesture {
                    search.init(id: <#T##ObjectIdentifier#>, searchType: "Birthday")
                    searchType = "Birthday"
                    presentUCV = true
                    self.frontCoverIsPersonalPhoto = 0

                }
                //.sheet(isPresented: $presentUCV)
                .sheet(item: )
                {_ in
                    let searchObject = SearchParameter.init(searchText: searchType)
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Thank You 🙏🏽").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Thanks")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Sympathy").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Sympathy")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
            }
            Section(header: Text("Life Events")) {
                Text("Graduation").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Graduation")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Promotion").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Promotion")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Good Luck").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Luck")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Engagement").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Engagement")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Wedding").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Wedding")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                //Text("Baby Shower")
                Text("Anniversery").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Anniversery")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Retirement").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Retirement")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
            }
            Section(header: Text("Spring")) {
                Text("Ramadan").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Ramadan")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Passover").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Passover")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Easter 🐇").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Easter")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                //Text("Kentucky Derby 🐎")
                //Text("Cinco De Mayo ")
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
                //Text("Juneteenth")
                //Text("Father's Day 🧔‍♂️")
                Text("Independence Day 🎆").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Fireworks")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
            }
            Section(header: Text("Fall")) {
                //Text("Labor Day")
                Text("Tailgate 🏈").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Football")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                //Text("Veteran's Day 🇺🇸")
                //Text("Rosh Hashana ✡️")
                //Text("Yom Kippur")
                Text("Halloween 🎃").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Halloween")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Thanksgiving 🦃").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Thanksgiving")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Apple Picking 🍎").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Apple")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
            }
            Section(header: Text("Winter")) {
                Text("Martin Luther King Jr. Day").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "MLK")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Super Bowl Sunday 🏟").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Football")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Mardi Gras").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Mardi%20Gras")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                //Text("Purim")
                Text("St. Patrick's Day 🍀").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Leprauchan")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Kwanzaa").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Kwanzaa")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Christmas 🎄").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Christmas")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("Hanukkah 🕎").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Hanukkah")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                Text("New Year's Eve").onTapGesture {
                    presentUCV = true
                    frontCoverIsPersonalPhoto = 0
                }.sheet(isPresented: $presentUCV) {
                    let searchObject = SearchParameter.init(searchText: "Fireworks")
                    UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
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
        }
    }
}
