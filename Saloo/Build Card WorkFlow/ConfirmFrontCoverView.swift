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
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    @EnvironmentObject var chosenOccassion: Occassion

    
    @State private var showUCV = false
    @State private var showCollageMenu = false

    @State var frontCoverImage: Image!
    @State var frontCoverPhotographer: String!
    @State var frontCoverUserName: String!
    @State private var segueToCollageMenu = false
    @State private var presentPrior = false

    var body: some View {
        NavigationView {
        VStack {
            Image(uiImage: UIImage(data: chosenObject.coverImage)!)
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
                //segueToCollageMenu = true
                showCollageMenu = true
                PhotoAPI.pingDownloadURL(downloadLocation: chosenObject.downloadLocation, completionHandler: { (response, error) in
                    if response != nil {
                        debugPrint("Ping Success!.......")
                        debugPrint(response)
                        }
                    if response == nil {
                        debugPrint("Ping Failed!.......")}})
            }.padding(.bottom, 10).fullScreenCover(isPresented: $showCollageMenu) {CollageStyleMenu()}
            Text("(Attribution Will Be Included on Back Cover)").font(.system(size: 12)).padding(.bottom, 20)
            }
        .navigationBarItems(leading:
            Button {
                print("Back button tapped")
                showUCV = true
            } label: {
                Image(systemName: "chevron.left").foregroundColor(.blue)
                Text("Back")
            })
        .fullScreenCover(isPresented: $showUCV) {UnsplashCollectionView()}
        }
    }
}
