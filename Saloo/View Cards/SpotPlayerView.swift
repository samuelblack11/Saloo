//
//  SpotPlayerView.swift
//  Saloo
//
//  Created by Sam Black on 2/16/23.
//

import Foundation

// https://santoshkumarjm.medium.com/how-to-design-a-custom-avplayer-to-play-audio-using-url-in-ios-swift-439f0dbf2ff2

import Foundation
import Foundation
import SwiftUI
import CoreData
import CloudKit
import StoreKit
import MediaPlayer

struct SpotPlayerView: View {
    @State var songID: String?
    @State var songName: String?
    @State var songArtistName: String?
    @State var songArtImageData: Data?
    @State var songDuration: Double?
    @State var songPreviewURL: String?
    @State private var songProgress = 0.0
    @State private var isPlaying = true
    @State var confirmButton: Bool
    @Binding var showFCV: Bool
    @State var spotDeviceID: String?
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @EnvironmentObject var spotifyAuth: SpotifyAuth
    var appRemote: SPTAppRemote? {get {return (sceneDelegate.appRemote)}}
    @State private var playBackStateCounter = 0

    var body: some View {
        NavigationStack {SpotPlayerView()}.environmentObject(appDelegate)
    }
    
    @ViewBuilder var selectButtonPreview: some View {
        if confirmButton == true {Button {showFCV = true; pausePlayback(); songProgress = 0.0} label: {Text("Select Song For Card").foregroundColor(.blue)}}
        else {Text("")}
    }
    
    @ViewBuilder var selectButton: some View {
        if confirmButton == true {Button {showFCV = true; pausePlayback(); songProgress = 0.0} label: {Text("Select Song For Card").foregroundColor(.blue)}}
        else {Text("")}
    }

    func convertToMinutes(seconds: Int) -> String {
        let m = seconds / 60
        let s = String(format: "%02d", seconds % 60)
        let completeTime = String("\(m):\(s)")
        return completeTime
    }
    
    func SpotPlayerView() -> some View {
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        return VStack {
                    Image(uiImage: UIImage(data: songArtImageData!)!)
                    Text(songName!)
                        .font(.headline)
                    Text(songArtistName!)
                    HStack {
                        Button {
                            songProgress = 0.0
                            playSong()
                            isPlaying = true
                        } label: {
                            ZStack {
                                Circle()
                                    .accentColor(.green)
                                    .shadow(radius: 10)
                                Image(systemName: "arrow.uturn.backward" )
                                    .foregroundColor(.white)
                                    .font(.system(.title))
                            }
                        }
                        .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
                        Button {
                            if spotifyAuth.playingSong {pausePlayback()}
                            else {playSong()}
                            isPlaying.toggle()
                            spotifyAuth.playingSong.toggle()
                        } label: {
                            ZStack {
                                Circle()
                                    .accentColor(.green)
                                    .shadow(radius: 10)
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                                    .font(.system(.title))
                            }
                        }
                        .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
                    }
                    ProgressView(value: songProgress, total: songDuration!)
                        .onReceive(timer) {_ in
                            if songProgress < songDuration! && spotifyAuth.playingSong {songProgress += 1}
                        }
                    HStack{
                        Text(convertToMinutes(seconds:Int(songProgress)))
                        Spacer()
                        Text(convertToMinutes(seconds: Int(songDuration!)-Int(songProgress)))
                            .padding(.trailing, 10)
                    }
                }
            .onAppear{playSong(); getPlayBackState()}
    }
    
    
    
    func runGetPlayBackState() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            //print("Running runGetToken....")
            if playBackStateCounter == 0 {if authCode != "" {getPlayBackState()}}
        }
    }
    
    
    func playSong() {
        SpotifyAPI().playSpotify(songID!, authToken: spotifyAuth.access_Token,deviceID: spotDeviceID!, songProgress: Int(songProgress))
        
    }
    
    func pausePlayback() {
        SpotifyAPI().pauseSpotify(songID, authToken: spotifyAuth.access_Token, deviceID: spotifyAuth.deviceID)
    }
    
    func getPlayBackState() {
        SpotifyAPI().getPlayBackState(authToken: spotifyAuth.access_Token, deviceID: spotifyAuth.deviceID, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    print("Running GPBS on SPV...")
                    print(response!.is_playing)
                    spotifyAuth.playingSong = response!.is_playing
                    isPlaying = true
                }
                if error != nil {
                    print("Error... \(error?.localizedDescription)")
                    
                }
            }
        })
    }
    
    
    
}
