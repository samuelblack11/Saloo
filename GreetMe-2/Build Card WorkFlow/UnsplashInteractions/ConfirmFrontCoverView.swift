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
    @ObservedObject var viewTransitions: ViewTransitions
    @State var frontCoverImage: Image!
    @State var frontCoverPhotographer: String!
    @State var frontCoverUserName: String!
    @State private var segueToCollageMenu = false
    @State var chosenObject: CoverImageObject
    @State private var presentPrior = false
    @Binding var frontCoverIsPersonalPhoto: Int
    @State var chosenCollection: ChosenCollection?
    @State var pageCount: Int

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
                //segueToCollageMenu = true
                viewTransitions.isShowingCollageMenu = true
                PhotoAPI.pingDownloadURL(downloadLocation: chosenObject.downloadLocation, completionHandler: { (response, error) in
                    if response != nil {
                        debugPrint("Ping Success!.......")
                        debugPrint(response)
                        }
                    if response == nil {
                        debugPrint("Ping Failed!.......")}})
            }.padding(.bottom, 10).sheet(isPresented: $viewTransitions.isShowingCollageMenu) {CollageStyleMenu(viewTransitions: viewTransitions, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto, chosenObject: chosenObject, chosenCollection: chosenCollection!)}
            Text("(Attribution Will Be Included on Back Cover)").font(.system(size: 12)).padding(.bottom, 20)
            }
        .navigationBarItems(leading:
            Button {
                print("Back button tapped")
                viewTransitions.isShowingUCV = true
            } label: {
                Image(systemName: "chevron.left").foregroundColor(.blue)
                Text("Back")
            })
        .fullScreenCover(isPresented: $viewTransitions.isShowingUCV) {
            UnsplashCollectionView(viewTransitions: viewTransitions, chosenCollection: chosenCollection!, pageCount: pageCount, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
        }
        }
    }
}
