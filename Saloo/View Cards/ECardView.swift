//
//  ECardView.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/10/23.
//

import Foundation
import SwiftUI
import CoreData
import CloudKit

struct eCardView: View {
    
    @State var eCardText: String
    @State var font: String
    @State var coverImage: Data
    @State var collageImage: Data
    @State var text1: String
    @State var text2: String
    @State var text2URL: URL
    @State var text3: String
    @State var text4: String
    @State var songID: String?
    @State var spotID: String?
    @State var songName: String?
    @State var songArtistName: String?
    @State var songArtImageData: Data?
    @State var songDuration: Double?
    @State var songPreviewURL: String?
    @State var showFCV: Bool = false
    @State var inclMusic: Bool
    @State var spotImageData: Data?
    @State var spotSongDuration: Double?
    @State var spotPreviewURL: String?
    let defaults = UserDefaults.standard
    @EnvironmentObject var appDelegate: AppDelegate
    @State var songAddedUsing: String?
    var appRemote2: SPTAppRemote? = SPTAppRemote(configuration: SPTConfiguration(clientID: "d15f76f932ce4a7c94c2ecb0dfb69f4b", redirectURL: URL(string: "saloo://")!), logLevel: .debug)
    
    
    var body: some View {
        HStack {
            VStack(spacing:1) {
                //Spacer()
                //Spacer()
                Image(uiImage: UIImage(data: coverImage)!)
                    .interpolation(.none).resizable().scaledToFit()
                Text(eCardText)
                    .font(Font.custom(font, size: 500)).minimumScaleFactor(0.01)
                Image(uiImage: UIImage(data: collageImage)!)
                    .interpolation(.high).resizable().scaledToFill()
                    .frame(width: UIScreen.screenHeight/4, height: UIScreen.screenHeight/4)

                //Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    VStack(spacing:0){
                        Text(text1)
                            .font(.system(size: 10)).frame(alignment: .center)
                        Link(text2, destination: text2URL)
                            .font(.system(size: 10)).frame(alignment: .center)
                        HStack(spacing: 0) {
                            Text(text3).font(.system(size: 4))
                                .frame(alignment: .center)
                            Link(text4, destination: URL(string: "https://unsplash.com")!)
                                .font(.system(size: 12)).frame(alignment: .center)
                        }
                    }
                    Spacer()
                    VStack(spacing:0) {
                        Text("Greeting Card").font(.system(size: 10))
                        Text("by").font(.system(size: 10))
                        Text("Saloo").font(.system(size: 10)).padding(.bottom,10).padding(.leading, 5)
                    }
                    Spacer()
                }
            }
            VStack(alignment: .center){
                Text("{Gift Card Will Go Here}")
                    .font(.system(size: 24)).frame(alignment: .center)
                    .multilineTextAlignment(.center)
                    .frame(maxHeight: .infinity)
                if inclMusic {
                    HStack(alignment: .bottom){
                        if appDelegate.musicSub.type == .Apple {
                            AMPlayerView(songID: songID, songName: songName, songArtistName: songArtistName, songArtImageData: songArtImageData, songDuration: songDuration, songPreviewURL: songPreviewURL, confirmButton: false, showFCV: $showFCV)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                    if appDelegate.musicSub.type == .Spotify {
                        HStack(alignment: .bottom){
                            SpotPlayerView(songID: spotID, songName: songName, songArtistName: songArtistName, songArtImageData: spotImageData, songDuration: spotSongDuration, songPreviewURL: spotPreviewURL, confirmButton: false, showFCV: $showFCV, appRemote2: appRemote2)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                    if appDelegate.musicSub.type == .Neither {
                        HStack(alignment: .bottom){
                            if songAddedUsing == "Apple" {
                                SongPreviewPlayer(songID: songID, songName: songName, songArtistName: songArtistName, songArtImageData: songArtImageData, songDuration: songDuration, songPreviewURL: songPreviewURL, confirmButton: false, showFCV: $showFCV, songAddedUsing: "Apple")
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                            }
                            if songAddedUsing == "Spotify" {
                                SongPreviewPlayer(songID: spotID, songName: songName, songArtistName: songArtistName, songArtImageData: spotImageData, songDuration: spotSongDuration, songPreviewURL: spotPreviewURL,confirmButton: false, showFCV: $showFCV, songAddedUsing: "Spotify")
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                            }
                        }
                    }
                }
            }
            .frame(width: UIScreen.screenWidth/2.1)
            .fixedSize(horizontal: true, vertical: false)
        }
        .onAppear {
            if appDelegate.musicSub.type == .Spotify {appRemote2?.connectionParameters.accessToken = (defaults.object(forKey: "SpotifyAccessToken") as? String)!}
        }
    }
}
