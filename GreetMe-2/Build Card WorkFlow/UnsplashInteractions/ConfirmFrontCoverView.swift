//
//  ConfirmFrontCoverView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//
// https://stackoverflow.com/questions/61237660/toggling-state-variables-using-ontapgesture-in-swiftui
// https://developer.apple.com/documentation/swiftui/link

import Foundation
import SwiftUI

struct ConfirmFrontCoverView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var frontCoverImage: Image!
    @State var frontCoverPhotographer: String!
    @State var frontCoverUserName: String!
    @State private var segueToCollageMenu = false
    @Binding var chosenObject: CoverImageObject!
    @Binding var collageImage: CollageImage!
    @Binding var noteField: NoteField!
    @State private var presentPrior = false
    @State var searchObject: SearchParameter
    @Binding var frontCoverIsPersonalPhoto: Int
    //@State var pageCount: Int
    @State var chosenCollection: ChosenCollection?

    var body: some View {
        NavigationView {
        VStack {
            Image(uiImage: UIImage(data: chosenObject.coverImage!)!)
                .resizable()
                .frame(width: 250, height: 250)
                .padding(.top, 50)
            VStack(spacing: 0) {
                Text("Photo By ")
                
                Link(String(chosenObject.coverImagePhotographer), destination: URL(string: "https://unsplash.com/@\(chosenObject.coverImageUserName)")!)
                Text(" On ")
                Link("Unsplash", destination: URL(string: "https://unsplash.com")!)
            }
            Spacer()
            Button("Confirm Image for Front Cover") {
                segueToCollageMenu = true
                PhotoAPI.pingDownloadURL(downloadLocation: chosenObject.downloadLocation, completionHandler: { (response, error) in
                    if response != nil {
                        debugPrint("Ping Success!.......")
                        debugPrint(response)
                        }
                    if response == nil {
                        debugPrint("Ping Failed!.......")}})
            }.padding(.bottom, 10).sheet(isPresented: $segueToCollageMenu) {CollageStyleMenu(collageImage: $collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: $chosenObject, noteField: $noteField, searchObject: searchObject)}
            Text("(Attribution Will Be Included on Back Cover)").font(.system(size: 12)).padding(.bottom, 20)
            }
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
            UnsplashCollectionView(searchParam: searchObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenCollection: chosenCollection!)
        }
        }
    }
}
