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
import StoreKit



struct MusicView: View {
    @State private var songSearch = ""

    
    
    
    
    var body: some View {
        TextField("Search Songs", text: $songSearch, onCommit: {
            print(self.songSearch)
        })
        .onAppear() {SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {Task{await AppleMusicAPI().fetchStorefrontID(completionHandler: {(response, error) in
            if response != nil {DispatchQueue.main.async {for item in response! {print(item)}}}
            if response != nil{print("No Reponse!")}
            else {debugPrint(error?.localizedDescription)}
            })}}}}
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding(.horizontal, 16)
        .accentColor(.pink)
        Text("----")
        //playSongView
    }
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
