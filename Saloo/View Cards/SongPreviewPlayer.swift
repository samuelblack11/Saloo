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
    @State private var player: AVPlayer?
    @EnvironmentObject var appDelegate: AppDelegate
    @State var songAddedUsing: MusicSubscriptionOptions
    @State var color: Color?
    var body: some View {NavigationStack {PreviewPlayerView()}.environmentObject(appDelegate)}
    
    @ViewBuilder var selectButtonPreview: some View {
        if confirmButton == true {Button {showFCV = true; player!.pause(); songProgress = 0.0} label: {Text("Select Song For Card").foregroundColor(.blue)}}
        else {Text("")}
    }
    
    
    func createPlayer() {
        let playerItem = AVPlayerItem(url: URL(string: songPreviewURL!)!)
        self.player = AVPlayer(playerItem: playerItem)
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
                    player!.seek(to: .zero)
                    player!.play()
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
                    if player!.timeControlStatus.rawValue == 2 {player!.pause()}
                    else {player!.play()}
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
                    if songProgress < 30 && player!.timeControlStatus.rawValue == 2 {songProgress += 1}
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
            createPlayer(); player!.play()
            if songAddedUsing == .Spotify{color = .green}
            else {color = .pink}
        }
        .onDisappear{player!.pause()}
    }
    
    func convertToMinutes(seconds: Int) -> String {
        let m = seconds / 60
        let s = String(format: "%02d", seconds % 60)
        let completeTime = String("\(m):\(s)")
        return completeTime
    }
}
