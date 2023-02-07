//
//  SpotPlayer.swift
//  Saloo
//https://sarunw.com/posts/uiviewcontroller-in-swiftui/
//  Created by Sam Black on 2/1/23.
//https://swiftdoc.org/v5.1/type/unmanaged/

import Foundation
import UIKit
import StoreKit
import SwiftUI
import MediaPlayer

class SpotAppRemoteVC: UIViewController, SPTAppRemoteUserAPIDelegate, SPTAppRemotePlayerStateDelegate {
    @State private var subscribedToPlayerState: Bool = false
    @State private var subscribedToCapabilities: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemMint
    }
    
    
    
    
    
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        
    }
    
    
    var appRemote: SPTAppRemote? {
        get {return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote}
    }
    var defaultCallback: SPTAppRemoteCallback {
        get {return {[weak self] _, error in if let error = error {print("***");print(error)}}}
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
            self.subscribedToPlayerState = true
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

            self.subscribedToCapabilities = true
            //self.updateCapabilitiesSubscriptionButtonState()
        })
    }
}


struct SpotPlayer2: UIViewControllerRepresentable {
    typealias UIViewControllerType = SpotAppRemoteVC

    func makeUIViewController(context: Context) -> SpotAppRemoteVC {
        //Return SpotAppRemoteVC Instance
        let vc = SpotAppRemoteVC()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SpotAppRemoteVC, context: Context) {
        //Updates the state of the specified view controller with new information from SwiftUI.
    }
    
}



struct SpotPlayer3: View {
    @State var isPresented = false
    var body: some View {
        Button("The View") {
            isPresented = true
        }
        .sheet(isPresented: $isPresented){SpotPlayer2().frame(height: 100)}
    }
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
    //@StateObject var spotAppRemote = SpotAppRemote()
    
    
    var body: some View {
        TextField("Search Songs", text: $songSearch, onCommit: {
            UIApplication.shared.resignFirstResponder()
            if self.songSearch.isEmpty {
                self.searchResults = []
            } else {
                print("calling!!!!")
                //spotAppRemote.appRemote?.authorizeAndPlayURI("")
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
            //if spotAppRemote.appRemote?.isConnected == false {
            //    if spotAppRemote.appRemote?.authorizeAndPlayURI("") == false {
            //        print("Ughhhh")
            //    }
            //}
        }
        .fullScreenCover(isPresented: $showApplePlayerView){ApplePlayer()}
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

class SpotAppRemote: SPTAppRemoteUserAPIDelegate, SPTAppRemotePlayerStateDelegate {
    
    let unManagedString = "" as CFString
    var unmanagedObject: Unmanaged<AnyObject> = .passUnretained(UnmanagedPlaceHolder())
    //A type for propogating an unmanaged object reference
    
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        
    }
    
    func isEqual(_ object: Any?) -> Bool {
        return true
    }
    
    var hash: Int = 0
    
    var superclass: AnyClass?
    
    func `self`() -> Self {
        return self
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return unmanagedObject
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return unmanagedObject
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return unmanagedObject
    }
    
    func isProxy() -> Bool {
        return true
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        return true
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        return true
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        return true
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        return true
    }
    
    var description: String = ""
    
}
