//
//  SnapShotCardForPrint.swift
//  GreetMe-2
//
//  Created by Sam Black on 6/19/22.
//

import Foundation
import SwiftUI

struct SnapShotCardForPrint: View {
    
    @ObservedObject var chosenObject: ChosenCoverImageObject
    @ObservedObject var collageImage: CollageImage
    @ObservedObject var noteField: NoteField
    @Binding var text1: String
    @Binding var text2: String
    @Binding var text2URL: URL
    @Binding var text3: String
    @Binding var text4: String
    @Binding var printCardText: String
    
    func coverSource() -> Image {
        if chosenObject.coverImage != nil {
            return Image(uiImage: UIImage(data: chosenObject.coverImage)!)
        }
        else {
            return Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: chosenObject.smallImageURLString)!))!)
        }
    }
    
    var body: some View {
        snapShotCardForPrintView
    }
    
    var snapShotCardForPrintView: some View {
        VStack(spacing: 1) {
        HStack {
            //upside down collage
            Image(uiImage: collageImage.collageImage)
                .resizable()
                .frame(width: (UIScreen.screenWidth/2.5), height: (UIScreen.screenWidth/2.5),alignment: .center)
                //.background(.white)
            //upside down message
            Text(printCardText)
                .frame(width: (UIScreen.screenWidth/2.5), height: (UIScreen.screenWidth/2.5),alignment: .center)
                .font(Font.custom(noteField.font, size: 24))
                .minimumScaleFactor(0.1)
                .foregroundColor(.black)
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
            }
            .rotationEffect(Angle(degrees: 180))
            .frame(width: (UIScreen.screenWidth/1.25), height: (UIScreen.screenHeight/2.5))

        // Front Cover & Back Cover
        HStack(spacing: 0) {
            //Back Cover
            VStack(spacing: 0) {
                Image(systemName: "greetingcard.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 64))
                Spacer()
                Text(text1)
                    .font(.system(size: 8))
                    .foregroundColor(.blue)
                Link(text2, destination: text2URL)
                    .font(.system(size: 8))
                HStack(spacing: 0) {
                    Text(text3).font(.system(size: 8)).foregroundColor(.blue)
                    Link(text4, destination: URL(string: "https://unsplash.com")!).font(.system(size: 8))
                }.padding(.bottom,10)
                //Text("Greeting Card by")
                    //.font(.system(size: 12))
                    //.foregroundColor(.blue)
                //Text("GreetMe Inc.")
                    //.font(.system(size: 12))
                    //.padding(.bottom,10)
                    //.foregroundColor(.blue)
                }
                //.background(.white)
            .frame(width: (UIScreen.screenWidth/2.5), height: (UIScreen.screenHeight/2.5))
            coverSource()
                .resizable()
                .frame(width: (UIScreen.screenWidth/2.5), height: (UIScreen.screenHeight/2.5))
            }//.background(.white)
        }
    }
}
