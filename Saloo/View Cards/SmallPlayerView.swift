//
//  SmallPlayerView.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/17/23.
//

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
    @State private var songProgress = 0.0
    @State private var isPlaying = true
    @State private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    @State var confirmButton: Bool
    @Binding var showFCV: Bool
    
    
    func smallPlayerView() -> some View {
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
        }
    }
    
    func convertToMinutes(seconds: Int) -> String {
        let m = seconds / 60
        let s = String(format: "%02d", seconds % 60)
        let completeTime = String("\(m):\(s)")
        return completeTime
    }
    
    
    var body: some View {
        smallPlayerView()
            .onAppear {
                self.musicPlayer.setQueue(with: [songID!])
                self.musicPlayer.play()
            }
        selectButton
    }
    
    @ViewBuilder var selectButton: some View {
        if confirmButton == true {Button {showFCV = true; musicPlayer.pause(); songProgress = 0.0} label: {Text("Select Song For Card").foregroundColor(.blue)}}
        else {Text("")}
    }
}
