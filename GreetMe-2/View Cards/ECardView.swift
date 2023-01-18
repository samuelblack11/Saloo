//
//  ECardView.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/10/23.
//

import Foundation
import SwiftUI
import CoreData
import CloudKit

struct eCardView: View {
    
    @State var eCardText: String
    @State var font: String
    @State var coverImage: Data
    @State var collageImage: Data
    @State var text1: String
    @State var text2: String
    @State var text2URL: URL
    @State var text3: String
    @State var text4: String
    @ObservedObject var chosenSong: ChosenSong
    
    var body: some View {
        HStack {
        VStack(spacing:1) {
            Image(uiImage: UIImage(data: coverImage)!)
                .interpolation(.none).resizable().scaledToFit()
            Text(eCardText)
                .font(Font.custom(font, size: 500)).minimumScaleFactor(0.01)
            Image(uiImage: UIImage(data: collageImage)!)
                .interpolation(.none).resizable().scaledToFit()
            Spacer()
            HStack(spacing: 0) {
                VStack(spacing:0){
                    Text(text1)
                        .font(.system(size: 10)).frame(alignment: .center)
                    Link(text2, destination: text2URL)
                        .font(.system(size: 10)).frame(alignment: .center)
                    HStack(spacing: 0) {
                        Text(text3).font(.system(size: 4))
                            .frame(alignment: .center)
                        Link(text4, destination: URL(string: "https://unsplash.com")!)
                            .font(.system(size: 12)).frame(alignment: .center)
                    }
                }
                Spacer()
                Image(systemName: "greetingcard.fill").foregroundColor(.blue).font(.system(size: 24))
                Spacer()
                VStack(spacing:0) {
                    Text("Greeting Card").font(.system(size: 10))
                    Text("by").font(.system(size: 10))
                    Text("GreetMe Inc.").font(.system(size: 10)).padding(.bottom,10).padding(.leading, 5)
                }
            }
        }
        
    }
        Spacer()
        MusicView.smallPlayerView()
        
    }
}
