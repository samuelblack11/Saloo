//
//  FinalizeCardView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//

import Foundation
import SwiftUI

struct Card {
    var card: Image
    var coverImage: Image
    var collage: Image
    var date: Date
    //var message: TextField
    var occassion: String
    var recipient: String
}

struct FinalizeCardView: View {
    
    @Binding var chosenObject: CoverImageObject!
    @Binding var collageImage: CollageImage!
    @Binding var noteField: NoteField!
    
    var body: some View {
        VStack(spacing: 0) {
            //collageImage
            //noteField
            HStack(spacing: 0) {
                //upside down collage
                collageImage.collageImage.resizable().frame(width: (UIScreen.screenWidth/2)-10, height: (UIScreen.screenWidth/2))
                //upside down message
                Text(noteField.noteText).frame(width: (UIScreen.screenWidth/2)-10, height: (UIScreen.screenWidth/2))
            }.rotationEffect(Angle(degrees: 180))
            // Front Cover & Back Cover
            HStack(spacing: 0) {
                //Back Cover
                VStack(spacing: 0) {
                    Image(systemName: "greetingcard.fill")
                        .foregroundColor(.blue)
                        //.imageScale(.medium)
                        .font(.system(size: 60))
                    Spacer()
                    Text("Front Cover By ").font(.system(size: 10))
                    Link(String(chosenObject.coverImagePhotographer), destination: URL(string: "https://unsplash.com/@\(chosenObject.coverImageUserName)")!).font(.system(size: 10))
                    HStack {
                    Text("On").font(.system(size: 10))
                    Link("Unsplash", destination: URL(string: "https://unsplash.com")!).font(.system(size: 10))
                    }.padding(.bottom,10)
                    Text("Greeting Card by").font(.system(size: 14))
                    Text("GreetMe Inc.").font(.system(size: 14))
                }.frame(width: (UIScreen.screenWidth/2)-10, height: (UIScreen.screenWidth/2))
                // Front Cover
                chosenObject.coverImage.resizable().frame(width: (UIScreen.screenWidth/2)-10, height: (UIScreen.screenWidth/2))
            }
        }
    }
}

// https://stackoverflow.com/questions/57727107/how-to-get-the-iphones-screen-width-in-swiftui
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
