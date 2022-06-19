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
        
        HStack(spacing: 0) {
            Image(uiImage: chosenObject.coverImage)
                .resizable()
                .frame(width: (UIScreen.screenHeight/3)-2, height: (UIScreen.screenHeight/3))
            Text(noteField.noteText)
                .scaledToFit()
                .minimumScaleFactor(0.3)
                .frame(width: (UIScreen.screenHeight/3)-2, height: (UIScreen.screenHeight/3))
            Image(uiImage: collageImage.collageImage)
                .resizable()
                .frame(width: (UIScreen.screenHeight/3)-2, height: (UIScreen.screenHeight/3))
        }//.rotationEffect(.degrees(90))
    }

    
    var body: some View {
        snapShotECardView
    }
        
    
    
    
    
}

