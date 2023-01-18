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


struct SmallPlayerView {
    @ObservedObject var chosenSong: ChosenSong
    @State private var songProgress = 0.0
    @State private var isPlaying = false

    
    func smallPlayerView() -> some View {
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        return  VStack {
            Image(uiImage: UIImage(data: chosenSong.artwork)!)
            Text(chosenSong.name)
                .font(.headline)
            Text(chosenSong.artistName)
            Spacer()
            HStack {
                Button {
                    self.musicPlayer.setQueue(with: [chosenSong.id])
                    self.musicPlayer.play()
                    songProgress = 0.0
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
                Button {
                    isPlaying.toggle()
                    if self.musicPlayer.playbackState.rawValue == 1 {self.musicPlayer.pause()}
                    else {self.musicPlayer.play()}
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
            }
            ProgressView(value: songProgress, total: chosenSong.durationInSeconds)
                .onReceive(timer) {_ in
                    if songProgress < chosenSong.durationInSeconds {
                        songProgress += 1
                    }
                }
            HStack{
                Text(convertToMinutes(seconds:Int(songProgress)))
                Spacer()
                Text(convertToMinutes(seconds: Int(chosenSong.durationInSeconds)-Int(songProgress)))
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
    }
}
