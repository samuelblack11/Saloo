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
import MediaPlayer

struct MusicSearchView: View {
    @EnvironmentObject var addMusic: AddMusic
    @EnvironmentObject var musicSub: MusicSubscription
    @EnvironmentObject var chosenSong: ChosenSong
    @EnvironmentObject var appDelegate: AppDelegate
    //@EnvironmentObject var sceneDelegate: SceneDelegate

    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var spotDeviceID: String = ""
    
    let devToken = "eyJhbGciOiJFUzI1NiIsImtpZCI6Ik5KN0MzVzgzTFoiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJCU00zWVpGVVQyIiwiZXhwIjoxNjg5MjQzOTI3LCJpYXQiOjE2NzM0Nzk1Mjd9.28_a1GIJEEKWzvJgmdM9lAmvB4ilY5pFx6TF0Q4uhIIKu8FR0fOaXd2-3xVHPWANA8tqbLurVE5yE8wEZEqR8g"
    @State private var songSearch = ""
    @State private var storeFrontID = "us"
    @State private var userToken = ""
    @State private var searchResults: [SongForList] = []
    //@State private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    @State private var player: AVPlayer?
    @State var showFCV: Bool = false
    @State private var showSPV = false
    @State private var isPlaying = false
    @State private var songProgress = 0.0
    @State private var connectToSpot = false
    
    func goToSpot() {connectToSpot = true}

    var body: some View {
        TextField("Search Songs", text: $songSearch, onCommit: {
            UIApplication.shared.resignFirstResponder()
            if self.songSearch.isEmpty {
                self.searchResults = []
            } else {
                switch appDelegate.musicSub.type {
                case .Apple:
                    return searchWithAM()
                case .Neither:
                    return searchWithAM()
                case .Spotify:
                    return goToSpot()
                }
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
        .onAppear{
            print("-----")
            print(appDelegate.musicSub.type)
            if appDelegate.musicSub.type == .Spotify {connectToSpot = true}
        }
        .popover(isPresented: $showSPV) {SmallPlayerView(songID: chosenSong.id, songName: chosenSong.name, songArtistName: chosenSong.artistName, songArtImageData: chosenSong.artwork, songDuration: chosenSong.durationInSeconds, songPreviewURL: chosenSong.songPreviewURL, confirmButton: true, showFCV: $showFCV)
        .presentationDetents([.fraction(0.4)])
        .fullScreenCover(isPresented: $showFCV) {FinalizeCardView()}
        }
        .sheet(isPresented: $connectToSpot){SpotPlayer().frame(height: 100)}
    }

}
extension MusicSearchView {
    
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
    

    func searchWithAM() {
        SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
            self.userToken = AppleMusicAPI().getUserToken()
            //self.storeFrontID = AppleMusicAPI().fetchStorefrontID(userToken: userToken)
            self.searchResults = AppleMusicAPI().searchAppleMusic(self.songSearch, storeFrontID: storeFrontID, userToken: userToken, completionHandler: { (response, error) in
                if response != nil {
                    DispatchQueue.main.async {
                        for song in response! {
                            let artURL = URL(string:song.attributes.artwork.url.replacingOccurrences(of: "{w}", with: "80").replacingOccurrences(of: "{h}", with: "80"))
                            let _ = getURLData(url: artURL!, completionHandler: { (artResponse, error2) in
                                let songForList = SongForList(id: song.attributes.playParams.id, name: song.attributes.name, artistName: song.attributes.artistName, artImageData: artResponse!, durationInMillis: song.attributes.durationInMillis, isPlaying: false, previewURL: song.attributes.previews[0].url)
                                searchResults.append(songForList)
                            })}}}; if response != nil {print("No Response!")}
                else {debugPrint(error?.localizedDescription)}}
            )}}
    }
    
    func getSongDetailsFromOtherService() {}
        
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
            
