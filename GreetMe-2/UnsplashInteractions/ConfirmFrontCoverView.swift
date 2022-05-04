//
//  ConfirmFrontCoverView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//

import Foundation
import SwiftUI

struct ConfirmFrontCoverView: View {
    
    // https://stackoverflow.com/questions/61237660/toggling-state-variables-using-ontapgesture-in-swiftui
    // https://developer.apple.com/documentation/swiftui/link
    @State var frontCoverImage: Image!
    @State var frontCoverPhotographer: String!
    @State var frontCoverUserName: String!
    @State private var segueToCollageMenu = false
    @Binding var chosenObject: CoverImageObject!
    @Binding var collageImage: CollageImage!
    @Binding var noteField: NoteField!

    var body: some View {
        VStack {
            chosenObject.coverImage.resizable().frame(width: 250, height: 250).padding(.top, 50)
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
                
            }.padding(.bottom, 10).sheet(isPresented: $segueToCollageMenu) {CollageStyleMenu(collageImage: $collageImage, chosenObject: $chosenObject, noteField: $noteField)}
            Text("(Attribution Will Be Included on Back Cover)").font(.system(size: 12)).padding(.bottom, 20)
        }
    }
}
