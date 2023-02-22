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
    //var appRemote: SPTAppRemote? {get {return (sceneDelegate.appRemote)}}
    @State private var playBackStateCounter = 0
    @State private var rungSongOnAppearCounter = 0
    @State private var addSongCounter = 0
    @State private var runningPlayPlaylist = 0
    @State private var songAddedToPlaylist = false
    @State private var beganPlayingSong = false
    @State private var triggerFirstSongPlay = false
    @State private var triggerAddSongToPlaylist = false
    @State private var showProgressView = true
    @State private var devIDCounter = 0
    @State private var clickedConfirm =  false
    let defaults = UserDefaults.standard
    var config = SPTConfiguration(clientID: "d15f76f932ce4a7c94c2ecb0dfb69f4b", redirectURL: URL(string: "saloo://")!)
    var appRemote2: SPTAppRemote
    //lazy var appRemote: SPTAppRemote = {
    //    print("instantiated appRemote...")
    //    let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
    //   appRemote.connectionParameters.accessToken = spotifyAuth.access_Token
    //   return appRemote
   // }()

    var body: some View {
        NavigationStack {SpotPlayerView()}.environmentObject(appDelegate)
    }
    
    
    @ViewBuilder var selectButton: some View {
        if confirmButton == true {Button {showFCV = true; spotifyAuth.songID = songID!} label: {Text("Select Song For Card").foregroundColor(.blue)}}
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
                   if showProgressView {ProgressView().progressViewStyle(.circular) .tint(.green)}
                    Image(uiImage: UIImage(data: songArtImageData!)!)
                    Text(songName!)
                        .font(.headline)
                    Text(songArtistName!)
                    HStack {
                        Button {
                            songProgress = 0.0
                            playSong()
                            isPlaying = true
                            spotifyAuth.playingSong = true
                        } label: {
                            ZStack {
                                Circle()
                                    .accentColor(.green)
                                    .shadow(radius: 8)
                                Image(systemName: "arrow.uturn.backward" )
                                    .foregroundColor(.white)
                                    .font(.system(.title))
                            }
                        }
                        .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
                        Button {
                            if spotifyAuth.playingSong {
                                pausePlayback()
                                
                                //appRemote?.playerAPI?.pause()
                            }
                            else {
                                playSong()
                            }
                            isPlaying.toggle()
                            spotifyAuth.playingSong.toggle()
                        } label: {
                            ZStack {
                                Circle()
                                    .accentColor(.green)
                                    .shadow(radius: 8)
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
                selectButton
                }
            .onAppear{
                triggerAddSongToPlaylist = true
                runAddSongToPlaylist()
                runPlayPlaylist()
            }
            .onDisappear{pausePlayback()}
    }

    func runGetPlayBackState() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            //print("Running runGetToken....")
            if playBackStateCounter == 0 {if spotifyAuth.playingSong {
                getPlayBackState()
                }
            }
        }
    }
    
    func runPlayPlaylist() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            //print("Running runGetToken....")
            if runningPlayPlaylist == 0 {if songAddedToPlaylist {
                //playPlaylist()
                print("Playlsit & Song IDs....")
                print(spotifyAuth.salooPlaylistID)
                print(songID)
                runningPlayPlaylist = 1
                //appRemote2.authorizeAndPlayURI("spotify:playlist:\(spotifyAuth.salooPlaylistID)")
                appRemote2.playerAPI?.play("spotify:playlist:\(spotifyAuth.salooPlaylistID)", asRadio: false, callback: defaultCallback)
                isPlaying = true
                beganPlayingSong = true
                spotifyAuth.playingSong = true
                }
            }
        }
    }
    func pausePlayback() {
        SpotifyAPI().pauseSpotify(songID, authToken: spotifyAuth.access_Token, deviceID: spotifyAuth.deviceID, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    print("Running PausePlayBack on SPV...")
                    print(response!)
                    isPlaying = false
                    spotifyAuth.playingSong = false
                    triggerFirstSongPlay = true
                    
                }
                if error != nil {
                    print("Error... \(error?.localizedDescription)")
                    
                }
            }
        })
    }
        
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[self] _, error in
                print("defaultCallBack Running...")
                print("started playing playlist")
                showProgressView = false
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    func runGetDevID() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            //print("Running runGetDevID....")
            if devIDCounter == 0 {if beganPlayingSong {getSpotDevices()}}
        }
    }
    
    
    func getSpotDevices() {
        print("Running getSpotDevices().....")
        devIDCounter = 1
        SpotifyAPI().getSpotDevices(authToken: spotifyAuth.access_Token, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    print("#####")
                    print("Running getSpotDevices()2...")
                    print(response!)
                    for device in response! {
                        print(device)
                        if device.type == "Smartphone" {
                            print("Device ID...\(device.id)")
                            spotDeviceID = device.id
                            spotifyAuth.deviceID = device.id
                            defaults.set(device.id, forKey: "SpotifyDeviceID")
                        }
                        break
                    }
                }
            }})
    }
    
    func runSongOnAppear() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            //print("Running runGetToken....")
            if rungSongOnAppearCounter == 0 {if triggerFirstSongPlay {
                rungSongOnAppearCounter = 1
                //appRemote?.authorizeAndPlayURI("spotify:track:\(songID!)")
                //playSong()
                //appRemote.playerAPI?.getPlayerState(defaultCallback)
                print("Is Connected?3")
                //print(appRemote?.isConnected)
                print(appRemote2.isConnected)
                //appRemote2.playerAPI?.getPlayerState()
                //appRemote2.authorizeAndPlayURI("spotify:track:\(songID)")
                //appRemote.playerAPI?.play(songID!, callback: defaultCallback)
                //appRemote2.playerAPI?.play("spotify:track:\(songID)", asRadio: false, callback: defaultCallback)

                isPlaying = true
                beganPlayingSong = true
                spotifyAuth.playingSong = true
                }
            }
        }
    }
    
    func getPlayBackState() {
        playBackStateCounter = 1
        SpotifyAPI().getPlayBackState(authToken: spotifyAuth.access_Token, deviceID: spotifyAuth.deviceID, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    print("Running GPBS on SPV...")
                    print(response!.is_playing)
                    spotifyAuth.playingSong = response!.is_playing
                    isPlaying = response!.is_playing
                }
                if error != nil {
                    print("Error... \(error?.localizedDescription)")
                    
                }
            }
        })
    }
    
    func runAddSongToPlaylist() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            //print("Running runGetToken....")
            if addSongCounter == 0 {if triggerAddSongToPlaylist {
                addSongToPlaylist()
                }
            }
        }
    }
    
    func addSongToPlaylist() {
        addSongCounter = 1
        SpotifyAPI().addToPlaylist(accessToken: spotifyAuth.access_Token, playlist_id: spotifyAuth.salooPlaylistID, songID: songID!, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    print("Running addSongToPlaylist on SPV...")
                    print(response!)
                    songAddedToPlaylist = true
                }
                if error != nil {
                    print("Error... \(error?.localizedDescription)")
                    
                }
            }
        })
    }
    
    
    func playPlaylist() {
        runningPlayPlaylist = 1
        SpotifyAPI().playPlaylist(spotifyAuth.salooPlaylistID, authToken: spotifyAuth.access_Token, deviceID: spotDeviceID!, songProgress: 0, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    print("Running playPlaylist on SPV...")
                    print(response!)
                    isPlaying = true
                    beganPlayingSong = true
                    spotifyAuth.playingSong = true
                }
                if error != nil {print("Error... \(error?.localizedDescription)")}
            }
        })
    }
    
    func playSong() {
        rungSongOnAppearCounter = 1
        SpotifyAPI().playSpotify(songID!, authToken: spotifyAuth.access_Token, deviceID: spotDeviceID!, songProgress: Int(songProgress), completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    print("Running PlaySong on SPV...")
                    print(response!)
                    print(response!.is_playing)
                    isPlaying = true
                    beganPlayingSong = true
                    spotifyAuth.playingSong = true
                }
                if error != nil {print("Error... \(error?.localizedDescription)")}
            }
        })
    }
}
