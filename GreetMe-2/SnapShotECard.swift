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
    
    var snapShotECardView: some View {
        
        HStack(spacing: 1) {
            Image(uiImage: chosenObject.coverImage)
                .resizable()
                .scaledToFill()
                .frame(width: (UIScreen.screenWidth/3)-10, height: (UIScreen.screenHeight/3))
                .border(Color.pink)
                .clipped()
            ZStack {
            Text(noteField.noteText)
                .minimumScaleFactor(0.3)
            }
                .background(.white)
                .foregroundColor(.black)
                .frame(width: (UIScreen.screenHeight/3)-10, height: (UIScreen.screenHeight/3))
            
            Image(uiImage: collageImage.collageImage)
                .resizable()
                .scaledToFill()
                .frame(width: (UIScreen.screenHeight/3)-10, height: (UIScreen.screenHeight/3))
                .border(Color.pink)
                .clipped()
        }
    }
    
    var body: some View {
        snapShotECardView
    }
        
    
    
    
    
}

