//
//  SnapShotECard.swift
//  GreetMe-2
//
//  Created by Sam Black on 6/19/22.
//

import Foundation
import SwiftUI

struct SnapShotECard: View {
    
    @Binding var chosenObject: CoverImageObject!
    @Binding var collageImage: CollageImage!
    @Binding var noteField: NoteField!
    @Binding var eCardText: String
    @Binding var text1: String
    @Binding var text2: String
    @Binding var text2URL: URL
    @Binding var text3: String
    @Binding var text4: String
    
    
    func coverSource() -> Image {
        if chosenObject.coverImage != nil {
            return Image(uiImage: UIImage(data: chosenObject.coverImage!)!)
        }
        else {
            return Image(uiImage: UIImage(data: try! Data(contentsOf: chosenObject.smallImageURL))!)
        }
    }
    
    var snapShotECardViewVertical: some View {
        VStack(spacing:1) {
            coverSource()
                .resizable()
                .scaledToFit()
                .frame(maxWidth: (UIScreen.screenWidth/1.5), maxHeight: (UIScreen.screenHeight/4))
            Text(eCardText)
                .font(Font.custom(noteField.font, size: 24))
                .foregroundColor(.black)
                .minimumScaleFactor(0.01)
                .frame(width: (UIScreen.screenWidth/1.5), height: (UIScreen.screenHeight/4))
            Image(uiImage: UIImage(data: collageImage.collageImage)!)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: (UIScreen.screenWidth/1.5), maxHeight: (UIScreen.screenHeight/4))
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing:0){
                    Text(text1)
                        .font(.system(size: 8))
                        .foregroundColor(.black)
                    Link(text2, destination: text2URL)
                        .font(.system(size: 8))
                    HStack(spacing: 0) {
                        Text(text3)
                            .font(.system(size: 8))
                            .foregroundColor(.black)
                        Link(text4, destination: URL(string: "https://unsplash.com")!).font(.system(size: 8))
                    }.padding(.bottom,10)
                }
                    Spacer()
                    Image(systemName: "greetingcard.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 36))
                        .padding(.bottom,10)
                    Spacer()
                //VStack(spacing:0) {
                    //Text("Greeting Card by").font(.system(size: 8))
                       // .foregroundColor(.black)
                    //Text("GreetMe Inc.").font(.system(size: 8))
                        //.foregroundColor(.black)
                //}
                Spacer()
                    }
                    .frame(maxWidth: (UIScreen.screenWidth/1.5), maxHeight: (UIScreen.screenHeight/10))
                    
            //}//.frame(height: (UIScreen.screenHeight/1.2))
        }.background(Color.white)
    }
    
    var body: some View {
        snapShotECardViewVertical
    }
    
    var snapShotECardView: some View {
        HStack(spacing: 1) {
            coverSource()
                .interpolation(.none)
                .resizable()
                .frame(width: (UIScreen.screenWidth/3)-2)
            
            ZStack {
            Color.white
            Text(eCardText)
                .foregroundColor(.black)
                .font(Font.custom(noteField.font, size: 500))
                .minimumScaleFactor(0.01)
                }
                .frame(width: (UIScreen.screenHeight/3)-10)

            Image(uiImage: UIImage(data:collageImage.collageImage)!)
                .interpolation(.none)
                .resizable()
                .frame(width: (UIScreen.screenHeight/3)-2)
        }.frame(height: (UIScreen.screenHeight/3)-5)
    }
}

