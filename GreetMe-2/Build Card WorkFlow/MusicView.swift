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


struct MusicView: View {
    let devToken = "eyJhbGciOiJFUzI1NiIsImtpZCI6Ik5KN0MzVzgzTFoiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJCU00zWVpGVVQyIiwiZXhwIjoxNjg5MjQzOTI3LCJpYXQiOjE2NzM0Nzk1Mjd9.28_a1GIJEEKWzvJgmdM9lAmvB4ilY5pFx6TF0Q4uhIIKu8FR0fOaXd2-3xVHPWANA8tqbLurVE5yE8wEZEqR8g"
    @State private var songSearch = ""
    @State private var storeFrontID = "us"
    @State private var userToken = ""
    @State private var searchResults: [SongForList] = []
    @State private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    @State private var isPlaying = false
    @State private var showFCV = false
    @ObservedObject var chosenSong = ChosenSong()
    
    @ObservedObject var chosenObject: ChosenCoverImageObject
    @ObservedObject var collageImage: CollageImage
    @ObservedObject var noteField = NoteField
    @ObservedObject var willHandWrite = HandWrite
    @ObservedObject var frontCoverIsPersonalPhoto: Int
    @State var text1: String
    @State var text2: String
    @State var text2URL: URL
    @State var text3: String
    @State var text4: String
    
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
                UIApplication.shared.resignFirstResponder()
                if self.songSearch.isEmpty {
                    self.searchResults = []
                } else {
                    SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
                        self.userToken = AppleMusicAPI().getUserToken()
                        //self.storeFrontID = AppleMusicAPI().fetchStorefrontID(userToken: userToken)
                        self.searchResults = AppleMusicAPI().searchAppleMusic(self.songSearch, storeFrontID: storeFrontID, userToken: userToken, completionHandler: { (response, error) in
                            if response != nil {
                                DispatchQueue.main.async {
                                    for song in response! {
                                        let artURL = URL(string:song.attributes.artwork.url.replacingOccurrences(of: "{w}", with: "80").replacingOccurrences(of: "{h}", with: "80"))
                                        let audioURL = URL(string:song.attributes.previews[0].url)
                                        let _ = getURLData(url: artURL!, completionHandler: { (artResponse, error2) in
                                            let _ = getURLData(url: audioURL!, completionHandler: { (audioResponse, error3) in
                                                let songForList = SongForList(id: song.attributes.playParams.id, name: song.attributes.name, artistName: song.attributes.artistName, artImageData: artResponse!, songPreview: audioResponse!, isPlaying: false)
                                                searchResults.append(songForList)
                                            })})}}}; if response != nil {print("No Response!")}
                            else {debugPrint(error?.localizedDescription)}})}}}})
            List {
                ForEach(searchResults, id: \.self) { song in
                    HStack {
                        Image(uiImage: UIImage(data: song.artImageData)!)
                        VStack{
                            Text(song.name)
                                .font(.headline)
                            Text(song.artistName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: {
                            // 3
                            print("Playing \(song.name)")
                            self.musicPlayer.setQueue(with: [song.id])
                            print(song.isPlaying)
                            song.isPlaying.toggle()
                            print(song.isPlaying)
                            self.musicPlayer.play()
                        }) {
                            ZStack {
                                Circle()
                                    //.frame(width: 80, height: 80)
                                    .accentColor(.pink)
                                    .shadow(radius: 10)
                                Image(systemName: song.isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                                    .font(.system(.title))
                            }
                        }
                    }
                    .onTapGesture {
                        showFCV = true
                        chosenSong.id = song.id
                        chosenSong.name = song.name
                        chosenSong.artistName = song.name
                        chosenSong.artwork = song.artImageData
                    }
                }
                .fullScreenCover(isPresented: $showFCV) {
                    FinalizeCardView(chosenObject: chosenObject, collageImage: collageImage, noteField: noteField, frontCoverIsPersonalPhoto: frontCoverIsPersonalPhoto, text1: $text1, text2: $text2, text2URL: $text2URL, text3: $text3, text4: $text4, willHandWrite: willHandWrite, eCardText: $eCardText, chosenOccassion: chosenOccassion)
                }
            }
            .onAppear() {}
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal, 16)
            .accentColor(.pink)
            Text("----")
            //playSongView
        }
    }

