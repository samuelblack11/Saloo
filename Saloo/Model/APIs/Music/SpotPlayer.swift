//
//  SpotPlayer.swift
//  Saloo
//
//  Created by Sam Black on 2/1/23.
//

import Foundation
import UIKit
import StoreKit
import SwiftUI
import MediaPlayer

struct SpotPlayer: View {
    
    @EnvironmentObject var chosenSong: ChosenSong

    @State private var showApplePlayerView = false
    @State private var songSearch = ""
    @State private var searchResults: [SongForList] = []
    @State private var isPlaying = false
    @State private var songProgress = 0.0
    @State private var showSPV = false
    @State var spotDeviceID: String = ""
    
    var appRemote: SPTAppRemote? {
        get {return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote}
    }
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[self] _, error in
                if let error = error {
                    print("***")
                    print(error)
                }
            }
        }
    }
    
    var body: some View {
        TextField("Search Songs", text: $songSearch, onCommit: {
            UIApplication.shared.resignFirstResponder()
            if self.songSearch.isEmpty {
                self.searchResults = []
            } else {
                searchWithSpotify()
            }}).padding(.top, 15)
        NavigationView {
            List {
                ForEach(searchResults, id: \.self) { song in
                    HStack {
                        Image(uiImage: UIImage(data: song.artImageData)!)
                        VStack{
                            Text(song.name)
                                .font(.headline)
                                .lineLimit(2)
                            Text(song.artistName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .frame(width: UIScreen.screenWidth, height: (UIScreen.screenHeight/7))
                    .onTapGesture {
                        print("Playing \(song.name)")
                        chosenSong.id = song.id; chosenSong.name = song.name
                        chosenSong.artistName = song.artistName; chosenSong.artwork = song.artImageData
                        chosenSong.durationInSeconds = Double(song.durationInMillis/1000)
                        chosenSong.songPreviewURL = song.previewURL
                        songProgress = 0.0; isPlaying = true; showSPV = true
                    }
                }
            }
        }
        .onAppear {
            appRemote!.connect()
            appRemote!.authorizeAndPlayURI("")
        }
        .fullScreenCover(isPresented: $showApplePlayerView){ApplePlayer()}
    }
}

extension SpotPlayer {
    func searchWithSpotify() {
        print("Testing....")
        SpotifyAPI().searchSpotify(self.songSearch, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    for song in response! {
                        print("BBBBB")
                        print(response)
                        let artURL = URL(string:song.album.images[2].url)
                        let _ = getURLData(url: artURL!, completionHandler: {(artResponse, error2) in
                            let songForList = SongForList(id: song.id, name: song.name, artistName: song.artists[0].name, artImageData: artResponse!, durationInMillis: song.duration_ms, isPlaying: false, previewURL: "")
                            searchResults.append(songForList)})
                    }}}; if response != nil {print("No Response!")}
                        else{debugPrint(error?.localizedDescription)}
        })
        
        print("%$%$")
        SpotifyAPI().getSpotDevices(completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    for device in response!.devices {
                        print("*&*&")
                        print(response)
                        if device.type == "Smartphone" {
                            spotDeviceID = device.id
                        }
                    }}}; if response != nil {print("No Response!")}
            else{debugPrint(error?.localizedDescription)}
        }
        )
        
    }
    
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
    
}
