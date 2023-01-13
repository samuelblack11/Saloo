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
    @State private var songs: [SongForList] = []
    //@State private var artData: Data?
    
    
    
    
    var body: some View {
        TextField("Search Songs", text: $songSearch, onCommit: {
            print(self.songSearch)
        })
        List {
            ForEach(songs, id: \.self) { song in
                VStack{
                    Text(song.name)
                        .font(.headline)
                    Text(song.artistName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Image(uiImage: getAlbumCover(song: song))
            }
        }
        
        
        
        
        
        .onAppear() {SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
            self.userToken = AppleMusicAPI().getUserToken()
            //self.storeFrontID = AppleMusicAPI().fetchStorefrontID(userToken: userToken)
            print(AppleMusicAPI().searchAppleMusic("Taylor Swift", storeFrontID: storeFrontID, userToken: userToken, completionHandler: { (response, error) in
                if response != nil {
                    DispatchQueue.main.async {
                        for song in response! {
                            let artURL = URL(string:song.attributes.artwork.url.replacingOccurrences(of: "{w}", with: "80").replacingOccurrences(of: "{h}", with: "80"))
                            let previewURL = URL(string:song.attributes.previews[0].url)
                            let songForList = SongForList(name: song.attributes.name, artistName: song.attributes.artistName, artwork: artURL!, songPreview: previewURL!)
                            songs.append(songForList)
                        }
                    }
                }
                if response != nil {print("No Response!")}
                else {debugPrint(error?.localizedDescription)}
            }))
            }}}
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding(.horizontal, 16)
        .accentColor(.pink)
        Text("----")
        //playSongView
    }
    
    
    
    
    
    }
    
//let dataTask = URLSession.shared.dataTask(with: artURL!) {(data, artResponse, error) in
//    if error != nil {return}
//    if let data = data {
//
//    }
//
//}

func getAlbumCover(song: SongForList) -> UIImage {
    var image: UIImage?
        let dataTask = URLSession.shared.dataTask(with: song.artwork) {(data, artResponse, error) in
            if error != nil {return}
            if let data = data {
                image =  UIImage(data: data)!
            }
        }
    return image!
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
