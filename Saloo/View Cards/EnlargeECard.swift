//
//  EnlargeECard.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/7/22.
//

import Foundation
import SwiftUI
import CloudKit
import MediaPlayer
import CoreData
import StoreKit
import WebKit
//https://www.appcoda.com/swiftui-confetti-animation/
struct EnlargeECardView: View {
    @State var chosenCard: CoreCard
    @State var share: CKShare?
    @State private var counter = 1
    private let stack = PersistenceController.shared
    @State var cardsForDisplay: [CoreCard]
    @State var whichBoxVal: InOut.SendReceive
    @EnvironmentObject var appDelegate: AppDelegate
    @State var player: AVPlayer?
    @State var refreshAccessToken = false
    @State private var tokenCounter = 0
    @State private var instantiateAppRemoteCounter = 0
    @State private var authCode: String? = ""
    @State private var refresh_token: String? = ""
    let defaults = UserDefaults.standard
    @State var spotifyAuth = SpotifyAuth()
    @State private var invalidAuthCode = false
    @State private var showWebView = false
    @State var appRemote2: SPTAppRemote?
    let config = SPTConfiguration(clientID: "d15f76f932ce4a7c94c2ecb0dfb69f4b", redirectURL: URL(string: "saloo://")!)
    @State var spotCounter = 0

    
    var body: some View {
        NavigationView {
            VStack {
                eCardView(eCardText: chosenCard.message, font: chosenCard.font, coverImage: chosenCard.coverImage!, collageImage: chosenCard.collage!, text1: chosenCard.an1, text2: chosenCard.an2, text2URL: URL(string: chosenCard.an2URL)!, text3: chosenCard.an3, text4: chosenCard.an4, songID: chosenCard.songID, spotID: chosenCard.spotID, songName: chosenCard.songName, songArtistName: chosenCard.songArtistName,songArtImageData: chosenCard.songArtImageData, songDuration: Double(chosenCard.songDuration!)!, songPreviewURL: chosenCard.songPreviewURL, inclMusic: chosenCard.inclMusic, spotImageData: chosenCard.spotImageData, spotSongDuration: Double(chosenCard.spotSongDuration!)!, spotPreviewURL: chosenCard.spotPreviewURL, songAddedUsing: chosenCard.songAddedUsing, cardType: chosenCard.cardType!)
            }
            //.onAppear{getSongFromOtherServiceIfNeeded()}
            
            }
        }
    
    
    func getSongFromOtherServiceIfNeeded() {
        print("gettingSongFromOtherService...")
        print(chosenCard.songAddedUsing as? String)
        print(appDelegate.musicSub.type)
        //if song from Apple and recip has SPOT
        // Search for song and associated data points using SPOT API
        if chosenCard.songAddedUsing == "Apple" && appDelegate.musicSub.type == .Spotify && chosenCard.spotID == chosenCard.spotID  {
            if appDelegate.musicSub.type == .Spotify {
                print("Run1")
                if defaults.object(forKey: "SpotifyAuthCode") != nil && spotCounter == 0 {
                    print("Run2")
                    refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
                    refreshAccessToken = true
                    runGetToken(authType: "refresh_token")
                    spotCounter += 1
                }
                else{print("Run3");requestSpotAuth(); runGetToken(authType: "code")}
                runInstantiateAppRemote()
            }
            getSongViaSpot()
        }
        //if song from SPOT and recip as Apple
        if chosenCard.songAddedUsing == "Spotify"  && appDelegate.musicSub.type == .Apple {
            //getSongViaAM()
            //update core data value for song id,
            
        }
        // if recip has neither and preview url is available
        // Just set songAddedUsing dependent on what musicSub the sender has. All required data is there.
        if appDelegate.musicSub.type == .Neither && chosenCard.spotPreviewURL == "" {chosenCard.songAddedUsing = "Apple"}
        if appDelegate.musicSub.type == .Neither && chosenCard.songPreviewURL == "" {chosenCard.songAddedUsing = "Spotify"}
    
    }
    }





extension EnlargeECardView {
    
    func getSongViaSpot() {
         SpotifyAPI().searchSpotify(chosenCard.songName, authToken: spotifyAuth.access_Token,completionHandler: {(response, error) in
             if response != nil {
                 DispatchQueue.main.async {
                     for song in response! {
                         if song.name == chosenCard.songName && song.artists[0].name == chosenCard.songArtistName {
                             print("SSSSS")
                             print(song)
                             let artURL = URL(string:song.album.images[2].url)
                             let _ = getURLData(url: artURL!, completionHandler: {(artResponse, error2) in
                                 chosenCard.spotID = song.id
                                 chosenCard.spotImageData = artResponse!
                                 chosenCard.spotSongDuration = String(Double(song.duration_ms))
                                 chosenCard.spotPreviewURL = song.preview_url
                             })}; break}}} else{debugPrint(error?.localizedDescription)}
         })
     }
    
    func getSpotToken() {
        print("called....requestSpotToken")
        tokenCounter = 1
        spotifyAuth.auth_code = authCode!
        SpotifyAPI().getToken(authCode: authCode!, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    spotifyAuth.access_Token = response!.access_token
                    spotifyAuth.refresh_Token = response!.refresh_token
                    defaults.set(response!.access_token, forKey: "SpotifyAccessToken")
                    defaults.set(response!.refresh_token, forKey: "SpotifyRefreshToken")
                }
            }
            if error != nil {
                print("Error... \(error?.localizedDescription)!")
                invalidAuthCode = true
                authCode = ""
            }
        })
    }
    
    func getSpotTokenViaRefresh() {
        print("called....requestSpotTokenViaRefresh")
        tokenCounter = 1
        spotifyAuth.auth_code = authCode!
        refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
        SpotifyAPI().getTokenViaRefresh(refresh_token: refresh_token!, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    spotifyAuth.access_Token = response!.access_token
                    defaults.set(response!.access_token, forKey: "SpotifyAccessToken")
                }
            }
            if error != nil {
                print("Error... \(error?.localizedDescription)!")
                invalidAuthCode = true
                authCode = ""
            }
        })
    }
    
    
    
    
    func runGetToken(authType: String) {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if tokenCounter == 0 && refreshAccessToken {
                if authType == "code" {if authCode != "" {getSpotToken()}}
                if authType == "refresh_token" {if refresh_token! != ""{getSpotTokenViaRefresh()}}
                if authCode == "AuthFailed" {
                    print("Unable to authorize")
                    tokenCounter = 1
                    appDelegate.musicSub.type = .Neither
                }
            }
        }
    }

    
    func requestSpotAuth() {
        print("called....requestSpotAuth")
        invalidAuthCode = false
        SpotifyAPI().requestAuth(completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    print("ccccccc")
                    print(response!)
                    if response!.contains("https://www.google.com/?code="){}
                    else{spotifyAuth.authForRedirect = response!; showWebView = true}
                    refreshAccessToken = true
                }}})
    }
    
    func runInstantiateAppRemote() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if instantiateAppRemoteCounter == 0 {if spotifyAuth.access_Token != "" {instantiateAppRemote()}}
        }
    }
    
    func instantiateAppRemote() {
        print("called....instantiateAppRemote")
        print(spotifyAuth.access_Token)
        instantiateAppRemoteCounter = 1
        DispatchQueue.main.async {
            appRemote2 = SPTAppRemote(configuration: config, logLevel: .debug)
            appRemote2?.connectionParameters.accessToken = spotifyAuth.access_Token
        }
    }
    
    //func getSongViaAM() {
   //     SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
    //        self.userToken = AppleMusicAPI().getUserToken()
    //        //self.storeFrontID = AppleMusicAPI().fetchStorefrontID(userToken: userToken)
     //       AppleMusicAPI().searchAppleMusic(chosenCard.songName, storeFrontID: storeFrontID, userToken: amAPI.taskToken!, completionHandler: {(response, error) in
     //           if response != nil {
     //               DispatchQueue.main.async {
     //                   for song in response! {
      //                      if song.attributes.name == chosenCard.songName && song.attributes.artistName == chosenCard.songArtistName {
      //                          let artURL = URL(string:song.attributes.artwork.url.replacingOccurrences(of: "{w}", with: "80").replacingOccurrences(of: "{h}", with: "80"))
     //                           let _ = getURLData(url: artURL!, completionHandler: { (artResponse, error2) in
     //                               chosenCard.songID = song.attributes.playParams.id
     //                               chosenCard.songArtImageData = artResponse!
     //                               chosenCard.songDuration = String(Double(song.attributes.durationInMillis/1000))
     //                               chosenCard.songPreviewURL = song.attributes.previews[0].url
     //                           });break}}}}else {debugPrint(error?.localizedDescription)}})}}
    //}
    

    
    
    
    private func string(for permission: CKShare.ParticipantPermission) -> String {
      switch permission {
      case .unknown:
        return "Unknown"
      case .none:
        return "None"
      case .readOnly:
        return "Read-Only"
      case .readWrite:
        return "Read-Write"
      @unknown default:
        fatalError("A new value added to CKShare.Participant.Permission")
      }
    }

    private func string(for role: CKShare.ParticipantRole) -> String {
      switch role {
      case .owner:
        return "Owner"
      case .privateUser:
        return "Private User"
      case .publicUser:
        return "Public User"
      case .unknown:
        return "Unknown"
      @unknown default:
        fatalError("A new value added to CKShare.Participant.Role")
      }
    }

    private func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
      switch acceptanceStatus {
      case .accepted:
        return "Accepted"
      case .removed:
        return "Removed"
      case .pending:
        return "Invited"
      case .unknown:
        return "Unknown"
      @unknown default:
        fatalError("A new value added to CKShare.Participant.AcceptanceStatus")
      }
    }
    
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
