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
        HStack(spacing: 0) {
            Image(uiImage: UIImage(data: chosenCard.coverImage!)!).resizable().frame(width: (UIScreen.screenHeight/3)-2, height: (UIScreen.screenHeight/3))
            Text(chosenCard.message!)
                .font(Font.custom(chosenCard.font!, size: 500))
                .minimumScaleFactor(0.01)
                .frame(width: (UIScreen.screenHeight/3)-2, height: (UIScreen.screenHeight/3))
            Image(uiImage: UIImage(data: chosenCard.collage!)!).resizable().frame(width: (UIScreen.screenHeight/3)-2, height: (UIScreen.screenHeight/3))
        }.rotationEffect(.degrees(90))
    }
    
    var body: some View {
        eCardView
    }
        

}
