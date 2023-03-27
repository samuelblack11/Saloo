//
//  AMPlayerView.swift
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

struct AMPlayerView: View {
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
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    var amAPI = AppleMusicAPI()
    @State private var ranAMStoreFront = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var fromFinalize = false
    @State var showWriteNote = false

    var body: some View {
            AMPlayerView
            .fullScreenCover(isPresented: $showWriteNote) {WriteNoteView()}
            .onAppear{if songArtImageData == nil{getAMUserToken(); getAMStoreFront()}}
            .navigationBarItems(leading:Button {
                if fromFinalize {musicPlayer.pause(); showWriteNote = true; }
                appDelegate.chosenGridCard = nil
            } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
    }
    
    var AMPlayerView: some View {
        VStack {
            if songArtImageData != nil {Image(uiImage: UIImage(data: songArtImageData!)!)}
            Text(songName!)
                .multilineTextAlignment(.center)
                .font(.headline)
            Text(songArtistName!)
                .multilineTextAlignment(.center)
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
                    if songProgress < songDuration! && musicPlayer.playbackState.rawValue == 1 {songProgress += 1}
                    if songProgress == songDuration {musicPlayer.pause()}
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
        .onDisappear{self.musicPlayer.pause()}
    }
    
    @ViewBuilder var selectButton: some View {
        if confirmButton == true {Button {showFCV = true; musicPlayer.pause(); songProgress = 0.0} label: {Text("Select Song For Card").foregroundColor(.blue)}}
        else {Text("")}
    }
    
    func convertToMinutes(seconds: Int) -> String {
        let m = seconds / 60
        let s = String(format: "%02d", seconds % 60)
        let completeTime = String("\(m):\(s)")
        return completeTime
    }
}

extension AMPlayerView {
    
    func getAMUserToken() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if amAPI.taskToken == nil {
                SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {amAPI.getUserToken(completionHandler: { ( response, error) in
                    print("Checking Token")
                    print(response)
                    print("^^")
                    print(error)
        })}}}}}

    func getAMStoreFront() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if amAPI.taskToken != nil && ranAMStoreFront == false {
                ranAMStoreFront = true
                SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
                    amAPI.storeFrontID = amAPI.fetchUserStorefront(userToken: amAPI.taskToken!, completionHandler: { ( response, error) in
                        amAPI.storeFrontID = response!.data[0].id
                        searchWithAM()
                    })}}}
            }
        }
            
    func searchWithAM() {
        SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
            AppleMusicAPI().searchAppleMusic("\(songName!) \(songArtistName!)", storeFrontID: amAPI.storeFrontID!, userToken: amAPI.taskToken!, completionHandler: { (response, error) in
                if response != nil {
                    DispatchQueue.main.async {
                        for song in response! {
                            if song.attributes.name == songName && song.attributes.artistName == songArtistName {
                                let blankString: String? = ""
                                var songPrev: String?
                                if song.attributes.previews.count > 0 {print("it's not nil"); songPrev = song.attributes.previews[0].url}
                                else {songPrev = blankString}
                                let artURL = URL(string:song.attributes.artwork.url.replacingOccurrences(of: "{w}", with: "80").replacingOccurrences(of: "{h}", with: "80"))
                                let _ = getURLData(url: artURL!, completionHandler: { (artResponse, error2) in
                                    songID = song.attributes.playParams.id
                                    songArtImageData = artResponse!
                                    songDuration = Double(song.attributes.durationInMillis) * 0.001
                                    songPreviewURL = songPrev!
                                    self.musicPlayer.setQueue(with: [songID!]); self.musicPlayer.play()
                                }); break}}}}
                else {debugPrint(error?.localizedDescription)}
        })}}}
    


    
    
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
