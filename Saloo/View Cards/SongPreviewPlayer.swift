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




class AudioURLPlayer: ObservableObject {
   @Published var player: AVPlayer?
    
    func playPreview(song: String) {
        if let url = URL(string: song) {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playback)
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                try audioSession.setActive(true)
                let playerItem = AVPlayerItem(url: url)
                self.player = AVPlayer.init(url: url)
                self.player?.automaticallyWaitsToMinimizeStalling = false
                self.player?.play()
                print("Player Item Status....")
            }
            catch {print(error.localizedDescription)}
        }
    }
    
}

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
    @State var audioPlayer: AVPlayer!
    @StateObject private var audioURLPlayer = AudioURLPlayer()
    
    
    var body: some View {NavigationStack {PreviewPlayerView()}.environmentObject(appDelegate)}
    
    @ViewBuilder var selectButtonPreview: some View {
        if confirmButton == true {Button {showFCV = true; audioURLPlayer.player?.pause(); songProgress = 0.0} label: {Text("Select Song For Card").foregroundColor(.blue)}}
        else {Text("")}
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
                    audioURLPlayer.player?.seek(to: .zero)
                    audioURLPlayer.player?.play()
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
                    if audioURLPlayer.player?.timeControlStatus.rawValue == 2 {audioURLPlayer.player?.pause()}
                    else {audioURLPlayer.player?.play()}
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
                    if songProgress < 30 && audioURLPlayer.player?.timeControlStatus.rawValue == 2 {songProgress += 1}
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
            audioURLPlayer.playPreview(song: songPreviewURL!)
            if songAddedUsing == "Spotify" {color = .green}
            else {color = .pink}
        }
        .onDisappear{
            audioURLPlayer.player?.pause()
            audioURLPlayer.player?.replaceCurrentItem(with: nil)
            audioURLPlayer.player = nil
        }
    }
    
    func convertToMinutes(seconds: Int) -> String {
        let m = seconds / 60
        let s = String(format: "%02d", seconds % 60)
        let completeTime = String("\(m):\(s)")
        return completeTime
    }
}
