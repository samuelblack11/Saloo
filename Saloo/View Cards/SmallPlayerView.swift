//
//  SmallPlayerView.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/17/23.
// https://santoshkumarjm.medium.com/how-to-design-a-custom-avplayer-to-play-audio-using-url-in-ios-swift-439f0dbf2ff2

import Foundation
import Foundation
import SwiftUI
import CoreData
import CloudKit
import StoreKit
import MediaPlayer

struct SmallPlayerView: View {
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
    @State private var player: AVPlayer?
    @State private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    @State var spotDeviceID: String?
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @EnvironmentObject var spotifyAuth: SpotifyAuth
    var appRemote: SPTAppRemote? {get {return (sceneDelegate.appRemote)}}
    
    var body: some View {
        NavigationStack {
            if appDelegate.musicSub.type == .Apple {AMPlayerView()}
            if appDelegate.musicSub.type == .Neither {AMPreviewPlayerView()}
            if appDelegate.musicSub.type == .Spotify {SpotPlayerView()}
            }
            .environmentObject(appDelegate)
    }
    

    
    @ViewBuilder var selectButtonPreview: some View {
        if confirmButton == true {Button {showFCV = true; player!.pause(); songProgress = 0.0} label: {Text("Select Song For Card").foregroundColor(.blue)}}
        else {Text("")}
    }
    
    @ViewBuilder var selectButton: some View {
        if confirmButton == true {Button {showFCV = true; musicPlayer.pause(); songProgress = 0.0} label: {Text("Select Song For Card").foregroundColor(.blue)}}
        else {Text("")}
    }
    
    func createPlayer() {
        let playerItem = AVPlayerItem(url: URL(string: songPreviewURL!)!)
        self.player = AVPlayer(playerItem: playerItem)
    }

    func AMPreviewPlayerView() -> some View {
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        return  VStack {
            Image(uiImage: UIImage(data: songArtImageData!)!)
            Text(songName!)
                .font(.headline)
            Text(songArtistName!)
            HStack {
                Button {
                    player!.seek(to: .zero)
                    player!.play()
                    songProgress = 0.0
                    isPlaying = true
                } label: {
                    ZStack {
                        Circle()
                            .accentColor(.pink)
                            .shadow(radius: 10)
                        Image(systemName: "arrow.uturn.backward" )
                            .foregroundColor(.white)
                            .font(.system(.title))
                    }
                }
                .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
                Button {
                    isPlaying.toggle()
                    if player!.timeControlStatus.rawValue == 2 {player!.pause()}
                    else {player!.play()}
                } label: {
                    ZStack {
                        Circle()
                            .accentColor(.pink)
                            .shadow(radius: 10)
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .font(.system(.title))
                    }
                }
                .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
            }
            ProgressView(value: songProgress, total: 30)
                .onReceive(timer) {_ in
                    if songProgress < 30 && player!.timeControlStatus.rawValue == 2 {
                        songProgress += 1
                    }
                }
            HStack{
                Text(convertToMinutes(seconds:Int(songProgress)))
                Spacer()
                Text(convertToMinutes(seconds: 30 - Int(songProgress)))
                    .padding(.trailing, 10)
            }
            selectButtonPreview
        }
        .onAppear{createPlayer(); player!.play()}
    }
    
    func AMPlayerView() -> some View {
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        return  VStack {
            Image(uiImage: UIImage(data: songArtImageData!)!)
            Text(songName!)
                .font(.headline)
            Text(songArtistName!)
            HStack {
                Button {
                    musicPlayer.setQueue(with: [songID!])
                    musicPlayer.play()
                    songProgress = 0.0
                    isPlaying = true
                } label: {
                    ZStack {
                        Circle()
                            .accentColor(.pink)
                            .shadow(radius: 10)
                        Image(systemName: "arrow.uturn.backward" )
                            .foregroundColor(.white)
                            .font(.system(.title))
                    }
                }
                .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
                Button {
                    isPlaying.toggle()
                    if musicPlayer.playbackState.rawValue == 1 {musicPlayer.pause()}
                    else {musicPlayer.play()}
                } label: {
                    ZStack {
                        Circle()
                            .accentColor(.pink)
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
                    if songProgress < songDuration! && musicPlayer.playbackState.rawValue == 1 {
                        songProgress += 1
                    }
                }
            HStack{
                Text(convertToMinutes(seconds:Int(songProgress)))
                Spacer()
                Text(convertToMinutes(seconds: Int(songDuration!)-Int(songProgress)))
                    .padding(.trailing, 10)
            }
            selectButton
        }
        .onAppear{self.musicPlayer.setQueue(with: [songID!]); self.musicPlayer.play()}
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
                            if songProgress < songDuration! && musicPlayer.playbackState.rawValue == 1 {songProgress += 1}
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
    
    
    func playSong() {
        SpotifyAPI().playSpotify(songID!, authToken: spotifyAuth.access_Token,deviceID: spotDeviceID!, songProgress: Int(songProgress), completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    print("Running PlaySong on SPV...")
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
    
    func pausePlayback() {
        SpotifyAPI().pauseSpotify(songID, authToken: spotifyAuth.access_Token, deviceID: spotifyAuth.deviceID, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    print("Running PausePlayback on SPV...")
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
