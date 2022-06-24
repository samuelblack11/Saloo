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
    
    
    func coverSource() -> Image {
        if chosenObject.coverImage != nil {
            return Image(uiImage: UIImage(data: chosenObject.coverImage!)!)
        }
        else {
            return Image(uiImage: UIImage(data: try! Data(contentsOf: chosenObject.smallImageURL))!)
        }
    }

    var snapShotECardView: some View {
        
        HStack(spacing: 1) {
            //Image(uiImage: UIImage(data: chosenObject.coverImage!)!)
            //Image(uiImage: UIImage(data: try! Data(contentsOf: chosenObject.smallImageURL))!)
            coverSource()
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: (UIScreen.screenWidth/3)-2, height: (UIScreen.screenHeight/3))
            
            ZStack {
            Color.white
            Text(eCardText)
                .font(.system(size: 500))
                .minimumScaleFactor(0.01)
                .foregroundColor(.black)
                }
                .frame(width: (UIScreen.screenHeight/3)-10, height: .infinity)

            Image(uiImage: collageImage.collageImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: (UIScreen.screenHeight/3)-2, height: (UIScreen.screenHeight/3))
        }.frame(height: (UIScreen.screenHeight/3))
    }
    
    var body: some View {
        snapShotECardView
    }
        
    
    
    
    
}

