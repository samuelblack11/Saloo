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
    var chosenCard: CoreCard
    @State var share: CKShare?
    @State private var counter = 1
    private let stack = PersistenceController.shared
    @State private var showGrid = false
    @State var cardsForDisplay: [CoreCard]
    @State var whichBoxVal: InOut.SendReceive
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var storeFrontID = "us"
    @State private var userToken = ""

    var body: some View {
        NavigationView {
            VStack {
                eCardView(eCardText: chosenCard.message, font: chosenCard.font, coverImage: chosenCard.coverImage!, collageImage: chosenCard.collage!, text1: chosenCard.an1, text2: chosenCard.an2, text2URL: URL(string: chosenCard.an2URL)!, text3: chosenCard.an3, text4: chosenCard.an4, songID: chosenCard.songID, spotID: chosenCard.spotID, songName: chosenCard.songName, songArtistName: chosenCard.songArtistName,songArtImageData: chosenCard.songArtImageData, songDuration: Double(chosenCard.songDuration!)!, songPreviewURL: chosenCard.songPreviewURL, inclMusic: chosenCard.inclMusic, spotImageData: chosenCard.spotImageData, spotSongDuration: Double(chosenCard.spotSongDuration!)!, spotPreviewURL: chosenCard.spotPreviewURL, songAddedUsing: chosenCard.songAddedUsing)
            }
            .navigationBarItems(
                leading:Button {showGrid = true}
                label: {Image(systemName: "chevron.left").foregroundColor(.blue)
                Text("Back")})
            .fullScreenCover(isPresented: $showGrid) {GridofCards(cardsForDisplay: cardsForDisplay, whichBoxVal: whichBoxVal)}
        }
        }
    
    
    func getSongFromOtherServiceIfNeeded() {
        //if song from Apple and recip has SPOT
        // Search for song and associated data points using SPOT API
        if chosenCard.songID != "" && appDelegate.musicSub.type == .Spotify {
            chosenCard.songAddedUsing = "Apple"
            //getSongViaSpot()
        }
        //if song from SPOT and recip as Apple
        if chosenCard.spotID != "" && appDelegate.musicSub.type == .Apple {
            chosenCard.songAddedUsing = "Spotify"
            getSongViaAM()
            //update core data value for song id,
            
        }
        // if recip has neither and preview url is available
        // Just set songAddedUsing dependent on what musicSub the sender has. All required data is there.
        if appDelegate.musicSub.type == .Neither && chosenCard.spotPreviewURL == "" {chosenCard.songAddedUsing = "Apple"}
        if appDelegate.musicSub.type == .Neither && chosenCard.songPreviewURL == "" {chosenCard.songAddedUsing = "Spotify"}
    
    }
    
    
    
    
    }




extension EnlargeECardView {
    
   // func getSongViaSpot() {
     //   SpotifyAPI().searchSpotify(chosenCard.songName, authToken: ,completionHandler: {(response, error) in
     //       if response != nil {
    //            DispatchQueue.main.async {
     //               for song in response! {
    //                    if song.name == chosenCard.songName && song.artists[0].name == chosenCard.songArtistName {
    //                        print("SSSSS")
    //                        print(song)
    //                        let artURL = URL(string:song.album.images[2].url)
    //                        let _ = getURLData(url: artURL!, completionHandler: {(artResponse, error2) in
     //                           chosenCard.spotID = song.id
     //                           chosenCard.spotImageData = artResponse!
     //                           chosenCard.spotSongDuration = String(Double(song.duration_ms))
     //                           chosenCard.spotPreviewURL = song.preview_url
     //                       })}; break}}} else{debugPrint(error?.localizedDescription)}
     //   })
   // }
    
    func getSongViaAM() {
        SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
            self.userToken = AppleMusicAPI().getUserToken()
            //self.storeFrontID = AppleMusicAPI().fetchStorefrontID(userToken: userToken)
            AppleMusicAPI().searchAppleMusic(chosenCard.songName, storeFrontID: storeFrontID, userToken: userToken, completionHandler: {(response, error) in
                if response != nil {
                    DispatchQueue.main.async {
                        for song in response! {
                            if song.attributes.name == chosenCard.songName && song.attributes.artistName == chosenCard.songArtistName {
                                let artURL = URL(string:song.attributes.artwork.url.replacingOccurrences(of: "{w}", with: "80").replacingOccurrences(of: "{h}", with: "80"))
                                let _ = getURLData(url: artURL!, completionHandler: { (artResponse, error2) in
                                    chosenCard.songID = song.attributes.playParams.id
                                    chosenCard.songArtImageData = artResponse!
                                    chosenCard.songDuration = String(Double(song.attributes.durationInMillis/1000))
                                    chosenCard.songPreviewURL = song.attributes.previews[0].url
                                });break}}}}else {debugPrint(error?.localizedDescription)}})}}
    }
    
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
