//
//  SpotPlayerView.swift
//  Saloo
//
//  Created by Sam Black on 2/16/23.
//

import Foundation

// https://santoshkumarjm.medium.com/how-to-design-a-custom-avplayer-to-play-audio-using-url-in-ios-swift-439f0dbf2ff2

import Foundation
import Foundation
import SwiftUI
import CoreData
import CloudKit
import StoreKit
import MediaPlayer

struct SpotPlayerView: View {
    let cleanMusicData = CleanMusicData()

    @State var songID: String?
    @State var songName: String?
    @State var songArtistName: String?
    @State var spotName: String?
    @State var spotArtistName: String?
    @State var songAlbumName: String?
    @State var songArtImageData: Data?
    @State var songDuration: Double?
    @State var songPreviewURL: String?
    @State var appleAlbumArtist: String?
    @State var spotAlbumArtist: String?
    @State private var songProgress = 0.0
    @State private var isPlaying = false
    @State var confirmButton: Bool
    @Binding var showFCV: Bool
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @State var spotifyAuth = SpotifyAuth()
    @State private var addSongCounter = 0
    @State private var showProgressView = true
    let defaults = UserDefaults.standard
    @State var accessedViaGrid = true
    @State var appRemote2: SPTAppRemote?
    @State private var refresh_token: String? = ""
    @State var counter = 0
    @State var refreshAccessToken = false
    @State private var authCode: String? = ""
    @State private var invalidAuthCode = false
    @State private var tokenCounter = 0
    @State private var instantiateAppRemoteCounter = 0
    let config = SPTConfiguration(clientID: "d15f76f932ce4a7c94c2ecb0dfb69f4b", redirectURL: URL(string: "saloo://")!)
    @State private var showWebView = false
    @State var associatedRecord: CKRecord?
    @State var coreCard: CoreCard?
    @State var levDistances: [Int] = []
    @State var spotAlbumID: String?
    @State var spotImageURL: String?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Binding var chosenCard: CoreCard?
    @Binding var deferToPreview: Bool
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showFailedConnectionAlert = false
    @State private var foundMatch3 = false
    

    
    var body: some View {
        SpotPlayerView2
            .onAppear{
                print("SPOT PLAYER APPEARED....")
                if accessedViaGrid && appDelegate.musicSub.type == .Spotify {getSpotCredentials{success in}}
                else{
                    if networkMonitor.isConnected{playSong()}
                    else {print("Connection failed3");showFailedConnectionAlert = true}
                }
            }
            .onDisappear{
                print("Did view disappear???")
                appRemote2?.playerAPI?.pause()
            }
            .navigationBarItems(leading:Button {chosenCard = nil
            } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
            // Show an alert if showAlert is true
            .alert(isPresented: $showFailedConnectionAlert) {
            Alert(title: Text("Network Error"), message: Text("Sorry, we weren't able to connect to the internet. Please reconnect and try again."), dismissButton: .default(Text("OK")))
        }
    }
    
    @ViewBuilder var selectButton: some View {
        if confirmButton == true {Button {
            print("Did Click....")
            
            appRemote2?.playerAPI?.pause();showFCV = true; spotifyAuth.songID = songID!} label: {Text("Select Song For Card").foregroundColor(.blue)}}
        else {Text("")}
    }
    
    func convertToMinutes(seconds: Int) -> String {
        let m = seconds / 60
        let s = String(format: "%02d", seconds % 60)
        let completeTime = String("\(m):\(s)")
        return completeTime
    }
    
    var SpotPlayerView2: some View {
        ZStack {
            //if showProgressView {ProgressView().progressViewStyle(.circular) .tint(.green).frame(maxWidth: UIScreen.screenHeight/9, maxHeight: UIScreen.screenHeight/9)}
            VStack {
                if songArtImageData != nil {Image(uiImage: UIImage(data: songArtImageData!)!) }
                Text(spotName!)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Text(spotArtistName!)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                HStack {
                    Button {
                        songProgress = 0.0
                        appRemote2?.playerAPI?.pause()
                        appRemote2?.playerAPI?.skip(toPrevious: defaultCallback)
                        appRemote2?.playerAPI?.resume()
                        isPlaying = true
                    } label: {
                        ZStack {
                            Circle()
                                .accentColor(.green)
                                .shadow(radius: 8)
                            Image(systemName: "arrow.uturn.backward" )
                                .foregroundColor(.white)
                                .font(.system(.title))
                        }
                    }
                    .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
                    Button {
                        if isPlaying {appRemote2?.playerAPI?.pause()}
                        else {appRemote2?.playerAPI?.resume()}
                        isPlaying.toggle()
                    } label: {
                        ZStack {
                            Circle()
                                .accentColor(.green)
                                .shadow(radius: 8)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .foregroundColor(.white)
                                .font(.system(.title))
                        }
                    }
                    .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
                }
                ProgressView(value: songProgress, total: songDuration!)
                    .onReceive(timer) {_ in
                        //if songProgress < songDuration! && isPlaying {songProgress += 1}
                        if let playerAPI = appRemote2?.playerAPI {
                            playerAPI.getPlayerState { (result, error) -> Void in
                                guard error == nil else {
                                    print("Error getting player state: \(error!)")
                                    return
                                }
                                guard let playbackPosition = (result as AnyObject).playbackPosition else {
                                    print("Error: Could not retrieve playback position.")
                                    return
                                }
                                // Use the unwrapped value of playbackPosition here
                                songProgress = Double(playbackPosition / 1000)
                            }
                        } else {
                            print("Error: Could not retrieve player API.")
                        }
                        
                        if songDuration! - songProgress == 1 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.99) {
                                appRemote2?.playerAPI?.pause()
                                isPlaying = false
                            }
                        }
                    }
                HStack{
                    Text(convertToMinutes(seconds:Int(songProgress)))
                    Spacer()
                    Text(convertToMinutes(seconds: Int(songDuration!)-Int(songProgress)))
                        .padding(.trailing, 10)
                }
                selectButton
            }
        }
        .onDisappear{appRemote2?.playerAPI?.seek(toPosition: 0)}
    }
    
    
    
    
    func concatAllArtists(song: SpotItem) -> String {
        var allArtists = String()
        if song.artists.count > 1 {
            for (index, artist) in song.artists.enumerated() {
                if index != 0 {
                    if song.name.lowercased().contains(artist.name.lowercased()) {}
                    else {allArtists = allArtists + " , " + artist.name}
                }
                else {allArtists = artist.name}
            }}
        else {allArtists = song.artists[0].name}
        return allArtists
    }
    
    
    func getSongViaAlbumSearch(completion: @escaping (Bool) -> Void) {
        let cleanAlbumNameForURL = cleanMusicData.compileMusicString(songOrAlbum: songAlbumName!, artist: nil, removeList: appDelegate.songFilterForMatch)
        let appleAlbumArtistForURL = cleanMusicData.cleanMusicString(input: appleAlbumArtist!, removeList: appDelegate.songFilterForMatch)
        let AMString = cleanMusicData.compileMusicString(songOrAlbum: songName!, artist: songArtistName!, removeList: appDelegate.songFilterForMatch)
        var foundMatch = false
        SpotifyAPI().getAlbumID(albumName: cleanAlbumNameForURL, artistName: appleAlbumArtistForURL , authToken: spotifyAuth.access_Token, completion: { (albums, error) in
            var albumIndex = 0
            func processAlbum() {
                guard albumIndex < albums!.count else {
                    // All albums processed or foundMatch4 is true
                    completion(foundMatch); return
                }
                let album = albums![albumIndex]
                albumIndex += 1
                print("Got Album...\(album.name)")
                let spotAlbumID = album.id // use the album ID from the current iteration
                SpotifyAPI().searchForAlbum(albumId: spotAlbumID, authToken: spotifyAuth.access_Token) { (albumResponse, error) in
                    if let album = albumResponse {
                        spotImageURL = album.images[2].url
                        getSpotAlbumTracks(spotAlbumID: spotAlbumID, AMString: AMString, completion: { foundMatch4 in
                            print("---foundMatch4: \(foundMatch4)")
                            if foundMatch4 == true {foundMatch = true; completion(foundMatch)}
                            else {processAlbum()}
                        })
                    } else {processAlbum()}
                }
            }
            processAlbum()
        })
    }

    
   
    
    func getSpotAlbumTracks(spotAlbumID: String, AMString: String, completion: @escaping (Bool) -> Void) {
        var foundMatch = false
        SpotifyAPI().getAlbumTracks(albumId: spotAlbumID, authToken: spotifyAuth.access_Token, completion: { (response, error) in
        innerLoop: for song in response! {
            print("Got Track...\(song.name)")
            var allArtists = concatAllArtists(song: song)
            let SPOTString = cleanMusicData.compileMusicString(songOrAlbum: song.name, artist: allArtists, removeList: appDelegate.songFilterForMatch)
            print("Track Name....AMString: \(AMString) && SPOTString: \(SPOTString)")
            if cleanMusicData.containsSameWords(AMString, SPOTString) && foundMatch == false {
                foundMatch = true
                print("SSSSS")
                print(song)
                let artURL = URL(string: spotImageURL!)
                let _ = getURLData(url: artURL!, completionHandler: {(artResponse, error2) in
                    spotName = song.name
                    spotArtistName = allArtists
                    songID = song.id
                    songArtImageData = artResponse!
                    songDuration = Double(song.duration_ms) * 0.001
                    playSong()
                    DispatchQueue.main.async {updateRecordWithNewSPOTData(spotName: song.name, spotArtistName: allArtists, spotID: song.id, songArtImageData: artResponse!, songDuration: String(Double(song.duration_ms) * 0.001)); return}
                    completion(foundMatch)

                    
                }); break innerLoop
            }}
            completion(foundMatch)
        })
    }
    
    
    
    
    
    
    
    func updateRecordWithNewSPOTData(spotName: String, spotArtistName: String, spotID: String, songArtImageData: Data, songDuration: String) {
        let controller = PersistenceController.shared
        let taskContext = controller.persistentContainer.newTaskContext()
        let ckContainer = PersistenceController.shared.cloudKitContainer
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        print("????")
        controller.updateRecordWithSpotData(for: coreCard!, in: taskContext, with: ckContainer.privateCloudDatabase, spotName: spotName, spotArtistName: spotArtistName,spotID: spotID, spotImageData: songArtImageData, spotSongDuration: songDuration, completion: { (error) in
            print("Updated Record...")
            print(error as Any)
        } )
    }

    func playSong() {
        print("network connected")
        //getSpotCredentials{success in
        if appRemote2?.isConnected == false {
            appRemote2?.authorizeAndPlayURI("spotify:track:\(songID!)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {appRemote2?.connect()}
        }
        appRemote2?.playerAPI?.pause(defaultCallback)
        appRemote2?.playerAPI?.enqueueTrackUri("spotify:track:\(songID!)", callback: defaultCallback)
        appRemote2?.playerAPI?.play("spotify:track:\(songID!)", callback: defaultCallback)
        isPlaying = true; showProgressView = false
        //}
    }
    
    
    
    
    

}

extension SpotPlayerView {
    
    func getSpotCredentials(completion: @escaping (Bool) -> Void) {
        print("Run1")
        if defaults.object(forKey: "SpotifyAuthCode") != nil && counter == 0 {
            print("Run2")
            refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
            refreshAccessToken = true
            if networkMonitor.isConnected {
                runGetToken(authType: "refresh_token")
                completion(true)
            } else {
                showFailedConnectionAlert = true
                completion(false)
            }
            counter += 1
        }
        else {
            print("Run3")
            if networkMonitor.isConnected {
                requestSpotAuth()
                runGetToken(authType: "code")
                completion(true)
            } else {
                showFailedConnectionAlert = true
                completion(false)
            }
        }
        if networkMonitor.isConnected {
            runInstantiateAppRemote()
            completion(true)
        } else {
            showFailedConnectionAlert = true
            completion(false)
        }
    }
    
    func requestSpotAuth() {
        print("called....requestSpotAuth")
        invalidAuthCode = false
        SpotifyAPI().requestAuth(completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    if response!.contains("https://www.google.com/?code="){}
                    else{spotifyAuth.authForRedirect = response!; showWebView = true}
                    refreshAccessToken = true
                }}})
    }
    
    func runGetToken(authType: String) {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if tokenCounter == 0 && refreshAccessToken {
                if authType == "code" {if authCode != "" {getSpotToken()}}
                if authType == "refresh_token" {if refresh_token! != ""{getSpotTokenViaRefresh()}}
            }
        }
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
                    if songID!.count == 0 {getSongViaAlbumSearch(completion: {(foundMatchBool)
                        in print("Did Find Match? \(foundMatchBool)")
                        if foundMatchBool == false {
                            if songPreviewURL != nil {
                                deferToPreview = true
                                //DispatchQueue.main.async {updateRecordWithNewSPOTData(spotName: "LookupFailed", spotArtistName: "LookupFailed", spotID: "LookupFailed", songArtImageData: Data(), songDuration: String(0))}
                            }
                            else { print("Else called to change card type...")
                                //appDelegate.chosenGridCard?.cardType = "noMusicNoGift"
                            }
                        }
                    })}
                }
            }
            if error != nil {
                print("Error... \(String(describing: error?.localizedDescription))!")
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
                    appRemote2?.connectionParameters.accessToken = spotifyAuth.access_Token
                    defaults.set(response!.access_token, forKey: "SpotifyAccessToken")
                    if songID!.count == 0 {getSongViaAlbumSearch(completion: {(foundMatchBool)
                        in print("Did Find Match? \(foundMatchBool)")
                        if foundMatchBool == false {
                            if songPreviewURL != nil {
                                deferToPreview = true
                                //DispatchQueue.main.async {updateRecordWithNewSPOTData(spotName: "LookupFailed", spotArtistName: "LookupFailed", spotID: "LookupFailed", songArtImageData: Data(), songDuration: String(0))}
                            }
                            else { print("Else called to change card type...")
                                //appDelegate.chosenGridCard?.cardType = "noMusicNoGift"
                            }
                        }
                    })}
                }
            }
            if error != nil {
                print("Error... \(String(describing: error?.localizedDescription))!")
                invalidAuthCode = true
                authCode = ""
            }
        })
    }
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[self] _, error in
                print("defaultCallBack Running...")
                showProgressView = false
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
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
            if spotName != "" && spotName != "LookupFailed" {playSong()}
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

extension String {
    var withoutPunc: String {
        return self.components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: "")
    }
}
