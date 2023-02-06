//
//  SpotPlayer.swift
//  Saloo
//
//  Created by Sam Black on 2/1/23.
//

import Foundation
import UIKit
import StoreKit
import SwiftUI
import MediaPlayer



class SpotAppRemote: SPTAppRemoteUserAPIDelegate, SPTAppRemotePlayerStateDelegate {
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        <#code#>
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        <#code#>
    }
    
    func isEqual(_ object: Any?) -> Bool {
        <#code#>
    }
    
    var hash: Int
    
    var superclass: AnyClass?
    
    func `self`() -> Self {
        <#code#>
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        <#code#>
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        <#code#>
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        <#code#>
    }
    
    func isProxy() -> Bool {
        <#code#>
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        <#code#>
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        <#code#>
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        <#code#>
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        <#code#>
    }
    
    var description: String
    
    
}



struct SpotPlayer: View {
    
    @EnvironmentObject var chosenSong: ChosenSong

    //https://developer.apple.com/documentation/swiftui/scenephase
    //@Environment(\.scenePhase) var scenePhase
    
    @State private var showApplePlayerView = false
    @State private var songSearch = ""
    @State private var searchResults: [SongForList] = []
    @State private var isPlaying = false
    @State private var songProgress = 0.0
    @State private var showSPV = false
    @State var spotDeviceID: String = ""
    @State private var subscribedToPlayerState: Bool = false
    @State private var subscribedToCapabilities: Bool = false
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[self] _, error in
                if let error = error {
                    print("***")
                    print(error)
                }
            }
        }
    }
    
    var appRemote: SPTAppRemote? {
        get {return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote}
    }
    
    var body: some View {
        TextField("Search Songs", text: $songSearch, onCommit: {
            UIApplication.shared.resignFirstResponder()
            if self.songSearch.isEmpty {
                self.searchResults = []
            } else {
                appRemote?.authorizeAndPlayURI("")
                //searchWithSpotify()
            }}).padding(.top, 15)
        NavigationView {
            List {
                ForEach(searchResults, id: \.self) { song in
                    HStack {
                        Image(uiImage: UIImage(data: song.artImageData)!)
                        VStack{
                            Text(song.name)
                                .font(.headline)
                                .lineLimit(2)
                            Text(song.artistName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .frame(width: UIScreen.screenWidth, height: (UIScreen.screenHeight/7))
                    .onTapGesture {
                        print("Playing \(song.name)")
                        chosenSong.id = song.id; chosenSong.name = song.name
                        chosenSong.artistName = song.artistName; chosenSong.artwork = song.artImageData
                        chosenSong.durationInSeconds = Double(song.durationInMillis/1000)
                        chosenSong.songPreviewURL = song.previewURL
                        songProgress = 0.0; isPlaying = true; showSPV = true
                    }
                }
            }
        }
        .onAppear {
            //appRemote!.connect()
            //.appRemote!.authorizeAndPlayURI("")
            print("%%%")
            print(appRemote?.isConnected)
            if appRemote?.isConnected == false {
                if appRemote?.authorizeAndPlayURI("") == false {
                    print("Ughhhh")
                }
            }
        }
        .fullScreenCover(isPresented: $showApplePlayerView){ApplePlayer()}
    }
    
    
    // MARK: - AppRemote
    func appRemoteConnecting() {
        //connectionIndicatorView.state = .connecting
    }

    func appRemoteConnected() {
        //connectionIndicatorView.state = .connected
        subscribeToPlayerState()
        subscribeToCapabilityChanges()
        getPlayerState()

        //enableInterface(true)
    }

    func appRemoteDisconnect() {
        //connectionIndicatorView.state = .disconnected
        subscribedToPlayerState = false
        subscribedToCapabilities = false
        //enableInterface(false)
    }
    
    private func subscribeToPlayerState() {
        guard (!subscribedToPlayerState) else { return }
        appRemote?.playerAPI!.delegate = self
        appRemote?.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            subscribedToPlayerState = true
            //self.updatePlayerStateSubscriptionButtonState()
        }
    }
    
    private func getPlayerState() {
        appRemote?.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }

            let playerState = result as! SPTAppRemotePlayerState
            //self.updateViewWithPlayerState(playerState)
        }
    }
    
    private func subscribeToCapabilityChanges() {
        guard (!subscribedToCapabilities) else { return }
        appRemote?.userAPI?.delegate = self
        appRemote?.userAPI?.subscribe(toCapabilityChanges: { (success, error) in
            guard error == nil else { return }

            subscribedToCapabilities = true
            //self.updateCapabilitiesSubscriptionButtonState()
        })
    }
    
    
    
    
    
    
}

extension SpotPlayer {
    func searchWithSpotify() {
        print("Testing....")
        SpotifyAPI().searchSpotify(self.songSearch, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    for song in response! {
                        print("BBBBB")
                        print(response)
                        let artURL = URL(string:song.album.images[2].url)
                        let _ = getURLData(url: artURL!, completionHandler: {(artResponse, error2) in
                            let songForList = SongForList(id: song.id, name: song.name, artistName: song.artists[0].name, artImageData: artResponse!, durationInMillis: song.duration_ms, isPlaying: false, previewURL: "")
                            searchResults.append(songForList)})
                    }}}; if response != nil {print("No Response!")}
                        else{debugPrint(error?.localizedDescription)}
        })
        
        print("%$%$")
        SpotifyAPI().getSpotDevices(completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    for device in response!.devices {
                        print("*&*&")
                        print(response)
                        if device.type == "Smartphone" {
                            spotDeviceID = device.id
                        }
                    }}}; if response != nil {print("No Response!")}
            else{debugPrint(error?.localizedDescription)}
        }
        )
        
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
