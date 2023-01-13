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
    @State private var storeFrontID = "us"
    @State private var userToken = ""

    
    
    
    
    var body: some View {
        TextField("Search Songs", text: $songSearch, onCommit: {
            print(self.songSearch)
        })
        .onAppear() {SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
            self.userToken = AppleMusicAPI().getUserToken()
            //self.storeFrontID = AppleMusicAPI().fetchStorefrontID(userToken: userToken)
            print("%%%%")
            print(self.storeFrontID)
            print(AppleMusicAPI().searchAppleMusic("Taylor Swift", storeFrontID: storeFrontID, userToken: userToken, completionHandler: { (response, error) in
                if response != nil {
                    DispatchQueue.main.async {
                        print("---")
                        print(response)
                        
                    }
                }
                if response != nil {print("No Response!")}
                else {debugPrint(error?.localizedDescription)}
            }))
            }
        }
        }
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
