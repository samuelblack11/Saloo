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
    let devToken = "eyJhbGciOiJFUzI1NiIsImtpZCI6Ik5KN0MzVzgzTFoiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJCU00zWVpGVVQyIiwiZXhwIjoxNjg5MjQzOTI3LCJpYXQiOjE2NzM0Nzk1Mjd9.28_a1GIJEEKWzvJgmdM9lAmvB4ilY5pFx6TF0Q4uhIIKu8FR0fOaXd2-3xVHPWANA8tqbLurVE5yE8wEZEqR8g"
    @State private var songSearch = ""
    @State private var storeFrontID = "us"
    @State private var userToken = ""
    @State private var songs: [SongForList] = []
    //@State private var artData: Data?
    
    
    func getURLData(url: URL, completionHandler: @escaping (Data?,Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {return}
            DispatchQueue.main.async {completionHandler(data, nil)}
        }
        dataTask.resume()
    }
    
    var body: some View {
        TextField("Search Songs", text: $songSearch, onCommit: {
            print(self.songSearch)
        })
        List {
            ForEach(songs, id: \.self) { song in
                HStack {
                    VStack{
                        Text(song.name)
                            .font(.headline)
                        Text(song.artistName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Image(uiImage: UIImage(data: song.artImageData)!)
                }
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
                            let audioURL = URL(string:song.attributes.previews[0].url)
                            let _ = getURLData(url: artURL!, completionHandler: { (artResponse, error2) in
            
                                let _ = getURLData(url: audioURL!, completionHandler: { (audioResponse, error3) in

                                let songForList = SongForList(name: song.attributes.name, artistName: song.attributes.artistName, artImageData: artResponse!, songPreview: audioResponse!)
                                songs.append(songForList)
                                })
                                
                            })
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
