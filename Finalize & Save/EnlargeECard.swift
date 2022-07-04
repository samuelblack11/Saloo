//
//  EnlargeECard.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/7/22.
//

import Foundation
import SwiftUI


struct EnlargeECardView: View {
    @Binding var chosenCard: Card!
    
    var eCardView: some View {
        VStack(spacing:1) {
            Image(uiImage: UIImage(data: chosenCard.coverImage!)!)
                .resizable()
                .frame(maxWidth: (UIScreen.screenWidth/1.5), maxHeight: (UIScreen.screenHeight/4))
            Text(chosenCard.message!)
                .font(Font.custom(chosenCard.font!, size: 500))
                .minimumScaleFactor(0.01)
                .frame(height: (UIScreen.screenHeight/4))
            
            HStack(spacing:1) {
                Image(uiImage: UIImage(data: chosenCard.collage!)!)
                    .resizable()
                    .frame(maxWidth: (UIScreen.screenWidth/1.9), maxHeight: (UIScreen.screenHeight/4))
                VStack(spacing: 0) {
                    Spacer()
                    Image(systemName: "greetingcard.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 36))
                        .padding(.bottom,10)
                    Spacer()
                    Text(chosenCard.an1!)
                        .font(.system(size: 8))
                    Link(chosenCard.an2!, destination: URL(string: chosenCard.an2URL!)!)
                        .font(.system(size: 8))
                    HStack(spacing: 0) {
                        Text(chosenCard.an3!).font(.system(size: 8))
                        Link(chosenCard.an4!, destination: URL(string: "https://unsplash.com")!).font(.system(size: 8))
                    }.padding(.bottom,10)
                    Spacer()
                    Text("Greeting Card by").font(.system(size: 8))
                    Text("GreetMe Inc.").font(.system(size: 8))
                }
            }.frame(maxHeight: (UIScreen.screenHeight/4))
        }.frame(height: (UIScreen.screenHeight/1.2))
    }
    
    var body: some View {
        eCardView
    }
        

}
