//
//  MusicView.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/9/23.
//

import Foundation
import SwiftUI
import CoreData
import CloudKit



struct MusicView: View {
    @State private var songSearch = ""

    
    
    
    
    var body: some View {
        TextField("Search Songs", text: $songSearch, onCommit: {
            print(self.songSearch)
        })
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding(.horizontal, 16)
        .accentColor(.pink)
        
        playSongView
    }
    
    
    
    
    
    
    
    
    
    
    var playSongView: some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: 80, height: 80)
                    .accentColor(.pink)
                    .shadow(radius: 10)
                Image(systemName: "backward.fill")
                    .foregroundColor(.white)
                    .font(.system(.title))
            }
            ZStack {
                Circle()
                    .frame(width: 80, height: 80)
                    .accentColor(.pink)
                    .shadow(radius: 10)
                Image(systemName: "pause.fill")
                    .foregroundColor(.white)
                    .font(.system(.title))
            }
        }
    }
}
