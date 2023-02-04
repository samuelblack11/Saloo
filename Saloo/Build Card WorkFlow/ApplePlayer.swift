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

struct ApplePlayer: View {
    let devToken = "eyJhbGciOiJFUzI1NiIsImtpZCI6Ik5KN0MzVzgzTFoiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJCU00zWVpGVVQyIiwiZXhwIjoxNjg5MjQzOTI3LCJpYXQiOjE2NzM0Nzk1Mjd9.28_a1GIJEEKWzvJgmdM9lAmvB4ilY5pFx6TF0Q4uhIIKu8FR0fOaXd2-3xVHPWANA8tqbLurVE5yE8wEZEqR8g"
    @State private var songSearch = ""
    @State private var storeFrontID = "us"
    @State private var userToken = ""
    @State private var searchResults: [SongForList] = []
    //@State private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    @State private var player: AVPlayer?
    @State var showFCV: Bool = false
    @State private var showSPV = false
    @ObservedObject var chosenSong: ChosenSong
    @State private var isPlaying = false
    @State private var songProgress = 0.0
    @ObservedObject var chosenOccassion: Occassion
    @ObservedObject var chosenObject: ChosenCoverImageObject
    @ObservedObject var collageImage: CollageImage
    @ObservedObject var noteField: NoteField
    @ObservedObject var addMusic: AddMusic
    @State var frontCoverIsPersonalPhoto: Int
    @State var eCardText: String
    @State var text1: String
    @State var text2: String
    @State var text2URL: URL
    @State var text3: String
    @State var text4: String
    @State private var connectToSpot = false
    @EnvironmentObject var musicSub: MusicSubscription

    var body: some View {
        TextField("Search Songs", text: $songSearch, onCommit: {
            UIApplication.shared.resignFirstResponder()
            if self.songSearch.isEmpty {
                self.searchResults = []
            } else {
                switch musicSub.type {
                case .Apple:
                    return searchWithAM()
                case .Neither:
                    return searchWithAM()
                case .Spotify:
                    return
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
            print(musicSub)
            if musicSub.type == .Spotify {connectToSpot = true}
        }
        .popover(isPresented: $showSPV) {SmallPlayerView(songID: chosenSong.id, songName: chosenSong.name, songArtistName: chosenSong.artistName, songArtImageData: chosenSong.artwork, songDuration: chosenSong.durationInSeconds, songPreviewURL: chosenSong.songPreviewURL, confirmButton: true, showFCV: $showFCV)
        .presentationDetents([.fraction(0.4)])
        .fullScreenCover(isPresented: $showFCV) {FinalizeCardView(chosenObject: chosenObject, collageImage: collageImage, noteField: noteField, frontCoverIsPersonalPhoto: frontCoverIsPersonalPhoto, text1: $text1, text2: $text2, text2URL: $text2URL, text3: $text3, text4: $text4, addMusic: addMusic, eCardText: $eCardText, chosenOccassion: chosenOccassion, chosenSong: chosenSong)}
        }
        .fullScreenCover(isPresented: $connectToSpot) {SpotPlayer(chosenSong: chosenSong)}
    }

}
extension ApplePlayer {

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
            
