//
//  SnapShotCardForPrint.swift
//  GreetMe-2
//
//  Created by Sam Black on 6/19/22.
//

import Foundation
import SwiftUI

struct SnapShotCardForPrint: View {
    
    @Binding var chosenObject: CoverImageObject!
    @Binding var collageImage: CollageImage!
    @Binding var noteField: NoteField!
    @Binding var text1: String
    @Binding var text2: String
    @Binding var text2URL: URL
    @Binding var text3: String
    @Binding var text4: String
    
    var body: some View {
        snapShotCardForPrintView
    }
    
    var snapShotCardForPrintView: some View {
        VStack(spacing: 1) {
        HStack {
            //upside down collage
            HStack {
                Image(uiImage: collageImage.collageImage)
                    .resizable()
                    .frame(width: (UIScreen.screenWidth/2.5)-10, height: (UIScreen.screenWidth/2.5),alignment: .center)
                }
                .frame(width: (UIScreen.screenWidth/2)-10, height: (UIScreen.screenWidth/2))
                .background(.white)

            //upside down message
            Text(noteField.noteText)
                .scaledToFill()
                .frame(width: (UIScreen.screenWidth/2)-20)
                //.font(.system(size: 4))
                .font(Font.custom("Papyrus", size: 4))
                .background(.white)
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
            }.rotationEffect(Angle(degrees: 180))
        // Front Cover & Back Cover
        HStack(spacing: 0) {
            //Back Cover
            VStack(spacing: 0) {
                Image(systemName: "greetingcard.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 48))
                Spacer()
                Text(text1)
                    .font(.system(size: 4))
                    .foregroundColor(.blue)
                    
                Link(text2, destination: text2URL)
                    .font(.system(size: 4))
                HStack(spacing: 0) {
                    Text(text3).font(.system(size: 4))                    .foregroundColor(.blue)

                    Link(text4, destination: URL(string: "https://unsplash.com")!).font(.system(size: 4))
                }.padding(.bottom,10)
                Text("Greeting Card by")
                    .font(.system(size: 6))
                    .foregroundColor(.blue)

                Text("GreetMe Inc.")
                    .font(.system(size: 6))
                    .padding(.bottom,10)
                    .foregroundColor(.blue)

                }
                .background(.white)
                .frame(width: (UIScreen.screenWidth/2)-10, height: (UIScreen.screenWidth/2))
            
            Image(uiImage: chosenObject.coverImage)
                .resizable()
                .frame(width: (UIScreen.screenWidth/2)-10, height: (UIScreen.screenWidth/2))
            }.background(.white)

        }
    }
}
