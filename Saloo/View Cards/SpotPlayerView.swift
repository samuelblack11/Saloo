//
//  SpotPlayerView.swift
//  Saloo
//
//  Created by Sam Black on 2/16/23.
//

import Foundation

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

    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    //@State var spotifyAuth = SpotifyAuth()
    @State private var showProgressView = true
    let defaults = UserDefaults.standard
    @State var accessedViaGrid = true
    @State private var refresh_token: String? = ""
    @State var counter = 0
    @State var refreshAccessToken = false
    @State private var authCode: String? = ""
    @State private var invalidAuthCode = false
    @State private var tokenCounter = 0
    @State private var showWebView = false
    @State var associatedRecord: CKRecord?
    @State var coreCard: CoreCard?
    @State var spotAlbumID: String?
    @State var spotImageURL: String?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Binding var chosenCard: CoreCard?
    @Binding var deferToPreview: Bool
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showFailedConnectionAlert = false
    @ObservedObject var gettingRecord = GettingRecord.shared
    @ObservedObject var spotifyManager = SpotifyManager.shared
    @State private var syncTimer: Timer? = nil
    @EnvironmentObject var chosenSong: ChosenSong
    @EnvironmentObject var appState: AppState
    @Binding var showSPV: Bool
    @Binding var isLoading: Bool
    //@Binding var disableTextField: Bool

    var body: some View {
        SpotPlayerView2
            .onAppear{
                
                if SpotifyAPI.shared.hasTokenExpired() {
                    print("Token expired....")
                    getSpotCredentials{success in}}
                else{
                    print("get song if needed...")
                    checkIfGetSongIsNeeded()}
            }
            .onDisappear{spotifyManager.appRemote?.playerAPI?.pause()}
            .navigationBarItems(leading:Button {chosenCard = nil
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
                print("::::")
                print(CardPrep.shared.chosenSong)
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
                        spotifyManager.appRemote?.playerAPI?.pause()
                        spotifyManager.appRemote?.playerAPI?.skip(toPrevious: spotifyManager.defaultCallback)
                        spotifyManager.appRemote?.playerAPI?.resume()
                        isPlaying = true
                    } label: {
                        ZStack {
                            Circle()
                                .accentColor(.green)
                                .shadow(radius: 10)
                            Image(systemName: "arrow.uturn.backward" )
                                .foregroundColor(.white)
                                .font(.system(.title))
                        }
                    }
                    .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
                    Button {
                        if isPlaying {spotifyManager.appRemote?.playerAPI?.pause()}
                        else {spotifyManager.appRemote?.playerAPI?.resume()}
                        isPlaying.toggle()
                    } label: {
                        ZStack {
                            Circle()
                                .accentColor(.green)
                                .shadow(radius: 10)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .foregroundColor(.white)
                                .font(.system(.title))
                        }
                    }
                    .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
                }
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
                    else {
                        ProgressView() // This is the built-in iOS activity indicator
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                    }
                }
                if confirmButton == true {selectButton}
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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


    private func stopTimer() {
        // Invalidate and deinitialize the timer
        self.syncTimer?.invalidate()
        self.syncTimer = nil
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
                    else {allArtists = allArtists + " & " + artist.name}
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
        SpotifyAPI.shared.getAlbumID(albumName: cleanAlbumNameForURL, artistName: appleAlbumArtistForURL , authToken: spotifyManager.access_token, completion: { (albums, error) in
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
                print(song)
                let artURL = URL(string: spotImageURL!)
                let _ = getURLData(url: artURL!, completionHandler: {(artResponse, error2) in
                    spotName = song.name
                    spotArtistName = allArtists
                    songID = song.id
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
        print("called playSong....")
        print(APIManager.shared.spotClientIdentifier)
        if let songID = songID {
            print("songID = songID")
            let trackURI = "spotify:track:\(songID)"
            if spotifyManager.appRemote?.isConnected == false {
                spotifyManager.appRemote?.connect()
                spotifyManager.appRemote?.authorizeAndPlayURI(trackURI)
                //spotifyManager.appRemote?.connect()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {spotifyManager.appRemote?.connect()}
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
            }
            else {showFailedConnectionAlert = true; completion(false)}
            counter += 1
        }
        else {
            print("Run3")
            if networkMonitor.isConnected {
                requestSpotAuth()
                runGetToken(authType: "code")
                completion(true)
            }
            else {showFailedConnectionAlert = true; completion(false)}
        }
        if networkMonitor.isConnected {completion(true)}
        else {showFailedConnectionAlert = true; completion(false)}
    }
    
    func requestSpotAuth() {
        print("called....requestSpotAuth")
        invalidAuthCode = false
        SpotifyAPI.shared.requestAuth(completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    if response!.contains("https://www.google.com/?code="){}
                    else{spotifyManager.authForRedirect = response!; showWebView = true}
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
    
    
    
    func checkIfGetSongIsNeeded() {
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
        else {
            if networkMonitor.isConnected{playSong()}
            else {showFailedConnectionAlert = true}
        }
    }
    
    
    func getSpotToken() {
        print("called....requestSpotToken")
        tokenCounter = 1
        spotifyManager.auth_code = authCode!
        SpotifyAPI.shared.getToken(authCode: authCode!, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    spotifyManager.access_token = response!.access_token
                    spotifyManager.appRemote?.connectionParameters.accessToken = spotifyManager.access_token
                    spotifyManager.refresh_token = response!.refresh_token
                    defaults.set(response!.access_token, forKey: "SpotifyAccessToken")
                    let expirationDate = Date().addingTimeInterval(response!.expires_in)
                    defaults.set(expirationDate, forKey: "SpotifyAccessTokenExpirationDate")
                    defaults.set(response!.refresh_token, forKey: "SpotifyRefreshToken")
                    checkIfGetSongIsNeeded()
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
        spotifyManager.auth_code = authCode!
        refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
        SpotifyAPI.shared.getTokenViaRefresh(refresh_token: refresh_token!, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    spotifyManager.access_token = response!.access_token
                    spotifyManager.appRemote?.connectionParameters.accessToken = spotifyManager.access_token
                    defaults.set(response!.access_token, forKey: "SpotifyAccessToken")
                    let expirationDate = Date().addingTimeInterval(response!.expires_in)
                    defaults.set(expirationDate, forKey: "SpotifyAccessTokenExpirationDate")
                    checkIfGetSongIsNeeded()
                }
            }
            if error != nil {
                print("Error... \(String(describing: error?.localizedDescription))!")
                invalidAuthCode = true
                authCode = ""
            }
        })
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
