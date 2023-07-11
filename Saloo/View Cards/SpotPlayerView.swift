//
//  SpotPlayerView.swift
//  Saloo
//
//  Created by Sam Black on 2/16/23.
//
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
    @State var songURL: String?
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @State private var showProgressView = true
    let defaults = UserDefaults.standard
    @State var accessedViaGrid = true
    @State private var refresh_token: String? = ""
    @State var counter = 0
    @State var refreshAccessToken = false
    @State private var authCode: String? = ""
    @State private var invalidAuthCode = false
    @State private var tokenCounter = 0
    @State var coreCard: CoreCard?
    @State var spotAlbumID: String?
    @State var spotImageURL: String?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Binding var chosenCard: CoreCard?
    @Binding var deferToPreview: Bool
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showFailedConnectionAlert = false
    @EnvironmentObject var gettingRecord:  GettingRecord
    @EnvironmentObject var spotifyManager: SpotifyManager
    @State private var syncTimer: Timer? = nil
    @EnvironmentObject var chosenSong: ChosenSong
    @EnvironmentObject var appState: AppState
    @Binding var showSPV: Bool
    @Binding var isLoading: Bool
    @State private var isSpotifyInstalled = true
    @ObservedObject var alertVars = AlertVars.shared
    let spotGreen = Color(red: 29.0 / 255.0, green: 185.0 / 255.0, blue: 84.0 / 255.0)
    //@Binding var disableTextField: Bool
    @State private var currentPlaybackPosition: Int = 0
    @State var fromFinalize = false
    @EnvironmentObject var cardProgress: CardProgress

    var body: some View {
        SpotPlayerView2
            .onAppear{
                    if let songIdUnwrapped = songID {spotifyManager.currentTrackId = songIdUnwrapped}
                    else { print("songID is nil")}
                    spotifyManager.updateCredentialsIfNeeded{success in
                        spotifyManager.verifySubType{isPremium in
                            if !isPremium {
                                alertVars.alertType = .spotNeedPremium
                                alertVars.activateAlert = true
                            }
                        }
                        spotifyManager.noInternet = {
                            alertVars.alertType = .failedConnection
                            alertVars.activateAlert = true
                        }
                        if networkMonitor.isConnected {checkIfGetSongIsNeeded()}
                }
            }
            .onChange(of: appState.pauseMusic) {shouldPause in if shouldPause{spotifyManager.appRemote?.playerAPI?.pause()}}
            .onDisappear{spotifyManager.appRemote?.playerAPI?.pause()}
            .navigationBarItems(leading:Button {chosenCard = nil; if fromFinalize {cardProgress.currentStep = 4; appState.currentScreen = .buildCard([.musicSearchView])}
            } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
            // Show an alert if showAlert is true
            .alert(isPresented: $showFailedConnectionAlert) {
            Alert(title: Text("Network Error"), message: Text("Sorry, we weren't able to connect to the internet. Please reconnect and try again."), dismissButton: .default(Text("OK")))
        }
    }
    
    @ViewBuilder var selectButton: some View {
        Button {
            //disableTextField = true
            spotifyManager.appRemote?.playerAPI?.pause()
            songProgress = 0.0
            self.showSPV = false
            self.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.isLoading = false
                CardPrep.shared.chosenSong = chosenSong
                CardPrep.shared.cardType = "musicNoGift"
                cardProgress.currentStep = 5
                appState.currentScreen = .buildCard([.finalizeCardView])
            }
        } label: {Text("Select Song For Card").foregroundColor(.blue)}
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
            VStack(alignment: .center) {
                if songArtImageData != nil {Image(uiImage: UIImage(data: songArtImageData!)!) }
                if let name = spotName, let urlString = songURL, let url = URL(string: urlString) {
                    Link(name, destination: url)
                }
                else{
                    Text(spotName ?? "Loading...")
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                Text(spotArtistName!)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                HStack {
                    Spacer()

                    // Nested HStack for buttons
                    HStack {
                        Button {
                            songProgress = 0.0
                            getCurrentTrack { currentlyPlayingTrackID in
                                if let trackID = currentlyPlayingTrackID {
                                    if trackID == "spotify:track:\(songID!)" && spotifyManager.appRemote?.isConnected == true {
                                        spotifyManager.appRemote?.playerAPI?.pause()
                                        spotifyManager.appRemote?.playerAPI?.skip(toPrevious: spotifyManager.defaultCallback)
                                        spotifyManager.appRemote?.playerAPI?.resume()
                                    }
                                    else {playSong()}
                                }
                                else {playSong()}
                            }
                            isPlaying = true
                        } label: {
                            ZStack {
                                Circle()
                                    .accentColor(spotGreen)
                                    .shadow(radius: 7)
                                Image(systemName: "arrow.uturn.backward" )
                                    .foregroundColor(.white)
                                    .font(.system(.title))
                            }
                        }
                        .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
                        Button {
                            if isPlaying {
                                spotifyManager.appRemote?.playerAPI?.pause()
                            } else {
                                getCurrentTrack { currentlyPlayingTrackID in
                                    if let trackID = currentlyPlayingTrackID {
                                        if trackID == "spotify:track:\(songID!)" && spotifyManager.appRemote?.isConnected == true {
                                            spotifyManager.appRemote?.playerAPI?.resume()
                                        }
                                        else {playSong()}
                                    }
                                    else {playSong()}
                                }
                            }
                            isPlaying.toggle()
                        } label: {
                            ZStack {
                                Circle()
                                    .accentColor(spotGreen)
                                    .shadow(radius: 7)
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                                    .font(.system(.title))
                            }
                        }
                        .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)


                    }

                    Spacer()
                }
                .overlay(
                    Image("SpotifyIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24) // height as per your text field
                        .padding([.top, .leading]), // add padding to top and leading
                    alignment: .bottomTrailing //
                )

                ProgressView(value: songProgress, total: songDuration!)
                    .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                        syncSongProgress()
                        //Check if song is almost over
                        if songDuration! - songProgress <= 1 {
                            // If the song is almost over, schedule the player to pause just before it ends
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.99) {
                                spotifyManager.appRemote?.playerAPI?.pause()
                                isPlaying = false
                            }
                        }
                    }


                    .onAppear {startTimer()}
                    .onDisappear{stopTimer()}
                HStack{
                    if songProgress >= 1.0 || songID == "" {
                        Text(convertToMinutes(seconds:Int(songProgress)))
                        Spacer()
                        Text(convertToMinutes(seconds: Int(songDuration!)-Int(songProgress)))
                            .padding(.trailing, 10)
                    }
                    else if isSpotifyInstalled {
                        ProgressView() // This is the built-in iOS activity indicator
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                    }
                }
                if confirmButton == true {selectButton}
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .onChange(of: spotifyManager.resetPlayerToStart) { isTrue in
            if isTrue {
                songProgress = 1.0
                isPlaying = false
                spotifyManager.resetPlayerToStart = false
            }
        }
        .onDisappear{spotifyManager.appRemote?.playerAPI?.seek(toPosition: 0)}
    }
    
    private func startTimer() {
        // Check if the song is playing
        spotifyManager.appRemote?.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else {
                print("Error getting player state: \(error!)")
                return
            }
            guard let playerState = (result as AnyObject).isPaused else {
                print("Error: Could not retrieve player state.")
                return
            }

            // If the song is playing, then start the timer
            if !playerState {
                // Instantiate and start the timer, syncing every 10 secondsf
                self.syncTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
                    self.syncSongProgress()
                }
            }
        }
    }
    
    func checkConnection() {
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            if spotifyManager.appRemote?.isConnected == false {spotifyManager.appRemote?.connect()}
        }
    }

    private func stopTimer() {
        // Invalidate and deinitialize the timer
        self.syncTimer?.invalidate()
        self.syncTimer = nil
    }
    
    func playSongFromLastPosition(clickedRestart: Bool) {
        let trackURI = "spotify:track:\(songID)"
        var startAt = Int()
        if clickedRestart {print("START AT 0"); startAt = 0}
        else {startAt = currentPlaybackPosition}
        spotifyManager.appRemote?.authorizeAndPlayURI(trackURI)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { // delay to ensure track has started playing
            spotifyManager.appRemote?.connect()
            spotifyManager.appRemote?.playerAPI?.seek(toPosition: startAt, callback: { (_, error) in
                if let error = error {print("Error seeking to position: \(error)")}
            })
        }
        isPlaying = true
        showProgressView = false
    }
    
    func getCurrentTrack(completion: @escaping (String?) -> Void) {
        guard let playerAPI = spotifyManager.appRemote?.playerAPI else {
            print("Spotify AppRemote not connected.")
            completion(nil)
            return
        }
        
        playerAPI.getPlayerState { (result, error) in
            if let error = error {
                print("Failed to get player state: \(error)")
                completion(nil)
            } else if let playerState = result as? SPTAppRemotePlayerState {
                let currentlyPlayingTrackID = playerState.track.uri
                completion(currentlyPlayingTrackID)
            }
        }
    }


    


    private func syncSongProgress() {
        // Sync the song progress
        if let playerAPI = spotifyManager.appRemote?.playerAPI {
            playerAPI.getPlayerState { (result, error) -> Void in
                guard error == nil else {
                    print("Error getting player state: \(error!)")
                    return
                }
                guard let playerState = result as? SPTAppRemotePlayerState else {
                    print("Error: Could not cast result to SPTAppRemotePlayerState.")
                    return
                }
                
                if playerState.isPaused {self.isPlaying = false}
                else {self.isPlaying = true}
                // Save the current position and track URI
                self.currentPlaybackPosition = playerState.playbackPosition
                guard let playbackPosition = (result as AnyObject).playbackPosition else {
                    print("Error: Could not retrieve playback position.")
                    return
                }
                // Use the unwrapped value of playbackPosition here
                DispatchQueue.main.async {self.songProgress = Double(playbackPosition / 1000)}
            }
        }
        else {print("Error: Could not retrieve player API.")}
    }

    
    func concatAllArtists(song: SpotItem) -> String {
        var allArtists = String()
        if song.artists.count > 1 {
            for (index, artist) in song.artists.enumerated() {
                if index != 0 {
                    if song.name.lowercased().contains(artist.name.lowercased()) {}
                    else {allArtists = allArtists + ", " + artist.name}
                }
                else {allArtists = artist.name}
            }}
        else {allArtists = song.artists[0].name}
        return allArtists
    }
    
    
    func getSongViaAlbumSearch(completion: @escaping (Bool) -> Void) {
        let cleanAlbumNameForURL = cleanMusicData.compileMusicString(songOrAlbum: songAlbumName!, artist: nil, removeList: appDelegate.songFilterForMatchRegex)
        var appleAlbumArtistForURL = String()
        if appleAlbumArtist != "" {appleAlbumArtistForURL = cleanMusicData.cleanMusicString(input: appleAlbumArtist!, removeList: appDelegate.songFilterForMatchRegex)}
        else {appleAlbumArtistForURL = cleanMusicData.cleanMusicString(input: songArtistName!, removeList: appDelegate.songFilterForMatchRegex)}
        let AMString = cleanMusicData.compileMusicString(songOrAlbum: songName!, artist: songArtistName!, removeList: appDelegate.songFilterForMatchRegex)
        var foundMatch = false
        SpotifyAPI.shared.getAlbumID(albumName: cleanAlbumNameForURL, artistName: appleAlbumArtistForURL, authToken: spotifyManager.access_token, completion: { (albums, error) in
            var albumIndex = 0
            func processAlbum() {
                guard albumIndex < albums!.count else {
                    print("called guard statement")
                    // All albums processed or foundMatch4 is true
                    completion(foundMatch); return
                }
                let album = albums![albumIndex]
                albumIndex += 1
                print("Got Album...\(album.name)")
                let spotAlbumID = album.id // use the album ID from the current iteration
                SpotifyAPI.shared.searchForAlbum(albumId: spotAlbumID, authToken: spotifyManager.access_token) { (albumResponse, error) in
                    if let album = albumResponse {
                        spotImageURL = album.images[2].url
                        getSpotAlbumTracks(spotAlbumID: spotAlbumID, AMString: AMString, completion: { foundMatch4 in
                            print("---foundMatch4: \(foundMatch4)")
                            if foundMatch4 == true {foundMatch = true; completion(foundMatch)}
                            else {processAlbum()}
                        })
                    } else {print("fail1");processAlbum()}
                }
            }
            print("fail2")
            processAlbum()
        })
    }
    
    func getSpotAlbumTracks(spotAlbumID: String, AMString: String, completion: @escaping (Bool) -> Void) {
        var foundMatch = false
        SpotifyAPI.shared.getAlbumTracks(albumId: spotAlbumID, authToken: spotifyManager.access_token, completion: { (response, error) in
        innerLoop: for song in response! {
            print("Got Track...\(song.name)")
            var allArtists = concatAllArtists(song: song)
            let SPOTString = cleanMusicData.compileMusicString(songOrAlbum: song.name, artist: allArtists, removeList: appDelegate.songFilterForMatchRegex)
            print("Track Name....AMString: \(AMString) && SPOTString: \(SPOTString)")
            if cleanMusicData.containsSameWords(AMString, SPOTString) && foundMatch == false {
                foundMatch = true
                print("SSSSS")
                print(allArtists)
                let artURL = URL(string: spotImageURL!)
                let _ = getURLData(url: artURL!, completionHandler: {(artResponse, error2) in
                    spotName = song.name
                    spotArtistName = allArtists
                    songID = song.id
                    if let songIdUnwrapped = songID {spotifyManager.currentTrackId = songIdUnwrapped}
                    else { print("songID is nil")}
                    songURL = song.external_urls?.spotify
                    songArtImageData = artResponse!
                    songDuration = Double(song.duration_ms) * 0.001
                    if networkMonitor.isConnected{playSong()}
                    else {showFailedConnectionAlert = true}
                    completion(foundMatch)
                }); break innerLoop
            }}
            completion(foundMatch)
        })
    }

    func playSong() {
        print(APIManager.shared.spotClientIdentifier)
        if let songID = songID {
            let trackURI = "spotify:track:\(songID)"
            if spotifyManager.appRemote?.isConnected == false {
                spotifyManager.appRemote?.connect()
                spotifyManager.appRemote?.authorizeAndPlayURI(trackURI)
                //spotifyManager.appRemote?.connect()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    spotifyManager.appRemote?.connect()
                    redirectToAppStore()
                }
            } else {
                spotifyManager.appRemote?.playerAPI?.pause(spotifyManager.defaultCallback)
                spotifyManager.appRemote?.playerAPI?.enqueueTrackUri(trackURI, callback: spotifyManager.defaultCallback)
                spotifyManager.appRemote?.playerAPI?.play(trackURI, callback: spotifyManager.defaultCallback)
            }

            isPlaying = true
            showProgressView = false
        } else {
            print("songID is nil")
        }
    }

    func redirectToAppStore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("+++")
            if let isConnected = spotifyManager.appRemote?.isConnected, !isConnected {
                self.showProgressView = false
                self.isSpotifyInstalled = false
                let spotifyAppStoreURL = URL(string: "https://apps.apple.com/app/spotify-music/id324684580")!
                UIApplication.shared.open(spotifyAppStoreURL)
            }
        }
    }

    
    
    
    

}

extension SpotPlayerView {
    
    func checkIfGetSongIsNeeded() {
        if songID!.count == 0 {getSongViaAlbumSearch(completion: {(foundMatchBool)
            in print("Did Find Match? \(foundMatchBool)")
            if foundMatchBool == false {
                if songPreviewURL != nil {
                    deferToPreview = true
                }
                else {chosenCard?.cardType = "noMusicNoGift"}
            }
        })}
        else {
            if networkMonitor.isConnected{playSong()}
            else {showFailedConnectionAlert = true}
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
    var withoutPunc: String {return self.components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: "")}
}
