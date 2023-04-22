//
//  SongPreviewPlayer.swift
//  Saloo
//
//  Created by Sam Black on 2/26/23.
//

import Foundation
import Foundation
import SwiftUI
import CoreData
import CloudKit
import StoreKit
import MediaPlayer
import AVFoundation
import AVFAudio
// https://santoshkumarjm.medium.com/how-to-design-a-custom-avplayer-to-play-audio-using-url-in-ios-swift-439f0dbf2ff2

struct SongPreviewPlayer: View {
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
    @EnvironmentObject var appDelegate: AppDelegate
    @State var songAddedUsing: String
    @State var color: Color?
    @State var player: AVPlayer?

    var body: some View {
        //NavigationView {
        PreviewPlayerView()
        //}
            .onAppear{print("PREVIEW PLAYER APPEARED....")}
            .navigationBarItems(leading:Button {
            player?.pause();player?.replaceCurrentItem(with: nil); appDelegate.chosenGridCard = nil
            } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
        
    }
        
    
    @ViewBuilder var selectButtonPreview: some View {
        if confirmButton == true {Button {showFCV = true; player?.pause(); songProgress = 0.0} label: {Text("Select Song For Card").foregroundColor(.blue)}}
        else {Text("")}
    }
    
    
    func createPlayer() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            try audioSession.setActive(true)
            let playerItem = AVPlayerItem(url: URL(string: songPreviewURL!)!)
            self.player = AVPlayer.init(playerItem: playerItem)
        }
        catch{print(error.localizedDescription)}
    }
    
    
    
    
    

    func PreviewPlayerView() -> some View {
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        return  VStack {
            Image(uiImage: UIImage(data: songArtImageData!)!)
            Text(songName!)
                .font(.headline)
            Text(songArtistName!)
            HStack {
                Button {
                    player?.seek(to: .zero)
                    player?.play()
                    songProgress = 0.0
                    isPlaying = true
                } label: {
                    ZStack {
                        Circle()
                            .accentColor(color)
                            .shadow(radius: 10)
                        Image(systemName: "arrow.uturn.backward" )
                            .foregroundColor(.white)
                            .font(.system(.title))
                    }
                }
                .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
                Button {
                    isPlaying.toggle()
                    if player?.timeControlStatus.rawValue == 2 {player?.pause()}
                    else {player?.play()}
                } label: {
                    ZStack {
                        Circle()
                            .accentColor(color)
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
                    if songProgress < 30 && player?.timeControlStatus.rawValue == 2 {songProgress += 1}
                }
            HStack{
                Text(convertToMinutes(seconds:Int(songProgress)))
                Spacer()
                Text(convertToMinutes(seconds: 30 - Int(songProgress)))
                    .padding(.trailing, 10)
            }
            selectButtonPreview
        }
        .onAppear{
            
            print("OnAppear Prev Player called")
            print(appDelegate.musicSub.type)
            print(appDelegate.deferToPreview )
            print(songName)

            createPlayer()
            player?.play()
            if songAddedUsing == "Spotify" {color = .green}
            else {color = .pink}
        }
    }
    
    func convertToMinutes(seconds: Int) -> String {
        let m = seconds / 60
        let s = String(format: "%02d", seconds % 60)
        let completeTime = String("\(m):\(s)")
        return completeTime
    }
}
