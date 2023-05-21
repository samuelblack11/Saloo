//
//  MusicView.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/9/23.
//

import Foundation
import SwiftUI
import CoreData
import CloudKit
import StoreKit
import MediaPlayer
import WebKit
struct MusicSearchView: View {
    @EnvironmentObject var addMusic: AddMusic
    @EnvironmentObject var musicSub: MusicSubscription
    @EnvironmentObject var chosenSong: ChosenSong
    @EnvironmentObject var appDelegate: AppDelegate
    @State var spotDeviceID: String = ""
    @State private var songSearch = ""
    @State private var artistSearch = ""
    @State private var albumSearch = ""
    @State private var storeFrontID = "us"
    @State private var userToken = ""
    @State private var searchResults: [SongForList] = []
    @EnvironmentObject var giftCard: GiftCard
    @EnvironmentObject var networkMonitor: NetworkMonitor

    let cleanMusicData = CleanMusicData()

    //@State private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    @State private var player: AVPlayer?
    @State var showFCV: Bool = false
    @State private var showAPV = false
    @State private var showSPV = false
    @State private var showWebView = false
    @State private var showWriteNote = false
    @State private var isPlaying = false
    @State private var songProgress = 0.0
    @EnvironmentObject var sceneDelegate: SceneDelegate
    //var appRemote: SPTAppRemote? {get {return (sceneDelegate.appRemote)}}
    @StateObject var spotifyAuth = SpotifyAuth()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var tokenCounter = 0
    @State private var instantiateAppRemoteCounter = 0
    @State private var authCode: String? = ""
    @State private var refresh_token: String? = ""
    @State private var invalidAuthCode = false
    let defaults = UserDefaults.standard
    let config = SPTConfiguration(clientID: "d15f76f932ce4a7c94c2ecb0dfb69f4b", redirectURL: URL(string: "saloo://")!)
    @State var appRemote2: SPTAppRemote?
    @State var counter = 0
    @State var refreshAccessToken = false
    @State private var ranAMStoreFront = false
    @State var amAPI = AppleMusicAPI()
    @State private var showSpotAuthFailedAlert = false
    let sortOptions = ["Track", "Artist","Album"]
    @State private var sortByValue = "Track"
    @State var emptyCard: CoreCard? = CoreCard()
    @State var deferToPreview = false
    @State private var showFailedConnectionAlert = false
    @State private var isLoading = false
    func determineCardType() -> String {
        var cardType2 = String()
        if chosenSong.id != nil && giftCard.id != ""  {cardType2 = "musicAndGift"}
        else if chosenSong.id != nil && giftCard.id == ""  {cardType2 = "musicNoGift"}
        else if chosenSong.id == nil && giftCard.id != ""  {cardType2 = "giftNoMusic"}
        else{cardType2 = "noMusicNoGift"}
        
        return cardType2
        
    }
    
    var sortResults: some View {
        HStack {
            Text("Sort By:").padding(.leading, 5).font(Font.custom(sortByValue, size: 12))
            Picker("", selection: $sortByValue) {ForEach(sortOptions, id:\.self) {sortOption in Text(sortOption)}}
            Spacer()
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if appDelegate.musicSub.type == .Spotify {
                    TextField("Track", text: $songSearch)
                    TextField("Artist", text: $artistSearch)
                    Button("Search"){
                        if networkMonitor.isConnected {searchWithSpotify()}
                        else {showFailedConnectionAlert = true}
                    }
                }
                else {
                    TextField("Search Songs", text: $songSearch, onCommit: {
                        UIApplication.shared.resignFirstResponder()
                        if networkMonitor.isConnected {
                            if self.songSearch.isEmpty {self.searchResults = []}
                            else  {
                                switch appDelegate.musicSub.type {
                                case .Apple: return searchWithAM()
                                case .Neither: return searchWithAM()
                                case .Spotify: return searchWithSpotify()
                                }
                            }
                        }
                        else {showFailedConnectionAlert = true}
                    }).padding(.top, 15)
                }
                LoadingOverlay()
            }
                NavigationView {
                    ZStack {
                        if isLoading {ProgressView().frame(width: UIScreen.screenWidth/2,height: UIScreen.screenHeight/2)}
                        List {
                            ForEach(searchResults, id: \.self) { song in
                                HStack {
                                    Image(uiImage: UIImage(data: song.artImageData)!)
                                    VStack{
                                        Text(song.name).font(.headline).lineLimit(2).frame(maxWidth: .infinity, alignment: .leading)
                                        Text(song.artistName).font(.caption).foregroundColor(.secondary).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Spacer()
                                }
                                .frame(width: UIScreen.screenWidth, height: (UIScreen.screenHeight/7))
                                .onTapGesture {print("Playing \(song.name)");createChosenSong(song: song)}
                            }
                        }
                    }
                }
                .onAppear{
                    if appDelegate.musicSub.type == .Spotify {getSpotCredentials{success in}}
                    if appDelegate.musicSub.type == .Apple {
                        if networkMonitor.isConnected {getAMUserTokenAndStoreFront{}}
                        else {showFailedConnectionAlert = true}}
                }
                .alert(isPresented: $showFailedConnectionAlert) {
                    Alert(title: Text("Network Error"), message: Text("Sorry, we weren't able to connect to the internet. Please reconnect and try again."), dismissButton: .default(Text("OK")))
                }
                .navigationBarItems(leading:Button {showWriteNote.toggle()} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
                .fullScreenCover(isPresented: $showWriteNote){WriteNoteView()}
                .popover(isPresented: $showAPV) {AMPlayerView(songID: chosenSong.id, songName: chosenSong.name, songArtistName: chosenSong.artistName, songArtImageData: chosenSong.artwork, songDuration: chosenSong.durationInSeconds, songPreviewURL: chosenSong.songPreviewURL, confirmButton: true, showFCV: $showFCV, chosenCard: $emptyCard, deferToPreview: $deferToPreview, showAPV: $showAPV)
                        .presentationDetents([.fraction(0.4)])
                        .fullScreenCover(isPresented: $showFCV) {FinalizeCardView(cardType: determineCardType())}
                        .fullScreenCover(isPresented: $showWriteNote){WriteNoteView()}
                }
                .popover(isPresented: $showSPV) {SpotPlayerView(songID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songArtImageData: chosenSong.spotImageData, songDuration: chosenSong.spotSongDuration, songPreviewURL: chosenSong.spotPreviewURL, confirmButton: true, showFCV: $showFCV, accessedViaGrid: false, appRemote2: appRemote2, chosenCard: $emptyCard, deferToPreview: $deferToPreview)
                        .presentationDetents([.fraction(0.4)])
                        .fullScreenCover(isPresented: $showFCV) {FinalizeCardView(cardType: determineCardType(), appRemote2: appRemote2)}
                        .fullScreenCover(isPresented: $showWriteNote) {WriteNoteView()}
                }
            .modifier(GettingRecordAlert())
            .environmentObject(spotifyAuth)
            .sheet(isPresented: $showWebView){WebVCView(authURLForView: spotifyAuth.authForRedirect, authCode: $authCode)}
        }
        .environmentObject(spotifyAuth)
    }

}

extension MusicSearchView {
    
    func getAMUserTokenAndStoreFront(completion: @escaping () -> Void) {
        getAMUserToken {[self] in self.getAMStoreFront(completion: completion)}
    }

    func getAMUserToken(completion: @escaping () -> Void) {
        SKCloudServiceController.requestAuthorization {(status) in
            if status == .authorized {
                amAPI.getUserToken { response, error in
                    print("Checking Token"); print(response); print("^^"); print(error)
                    completion()
                }
            }
        }
    }

    func getAMStoreFront(completion: @escaping () -> Void) {
        SKCloudServiceController.requestAuthorization {(status) in
            if status == .authorized {
                amAPI.fetchUserStorefront(userToken: amAPI.taskToken!) { response, error in
                    amAPI.storeFrontID = response!.data[0].id
                    completion()
                }
            }
        }
    }
    
    func searchWithAM() {
        if amAPI.storeFrontID == nil {isLoading = true; getAMUserTokenAndStoreFront{performAMSearch()}}
        else {performAMSearch()}
    }
    
    func performAMSearch() {
        isLoading = true
        SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
            let amSearch = cleanMusicData.cleanMusicString(input: self.songSearch, removeList: appDelegate.songFilterForSearch)
            self.searchResults = AppleMusicAPI().searchAppleMusic(amSearch, storeFrontID: amAPI.storeFrontID!, userToken: amAPI.taskToken!, completionHandler: { (response, error) in
                if response != nil {
                    DispatchQueue.main.async {
                        for song in response! {
                            let blankString: String? = ""
                            var songPrev: String?
                            if song.attributes.previews.count > 0 {songPrev = song.attributes.previews[0].url}
                            else {songPrev = blankString}
                            print("Search With AM called...")
                            let artURL = URL(string:song.attributes.artwork.url.replacingOccurrences(of: "{w}", with: "80").replacingOccurrences(of: "{h}", with: "80"))
                            let _ = getURLData(url: artURL!, completionHandler: { (artResponse, error2) in
                                print("Song Name is...\(song.attributes.name)")
                                let songForList = SongForList(id: song.attributes.playParams.id, name: song.attributes.name, artistName: song.attributes.artistName, albumName: song.attributes.albumName,artImageData: artResponse!, durationInMillis: song.attributes.durationInMillis, isPlaying: false, previewURL: songPrev!, disc_number: song.attributes.discNumber)
                                if cleanMusicData.containsString(listOfSubStrings: appDelegate.songFilterForSearch, songName: songForList.name) || cleanMusicData.containsString(listOfSubStrings: appDelegate.songFilterForSearch, songName: songForList.albumName){
                                print("Did Not Append....")
                                print(songForList.name)
                            }
                            else {searchResults.append(songForList)}
                            })}}}; if response != nil {print("No Response!")}
                else {debugPrint(error?.localizedDescription)}}
            )}}
        isLoading = false
    }
    
    func createChosenSong(song: SongForList) {

        songProgress = 0.0; isPlaying = true
        if appDelegate.musicSub.type == .Spotify {
            chosenSong.spotID = song.id
            chosenSong.spotName = song.name
            chosenSong.spotArtistName = song.artistName
            chosenSong.songAlbumName = song.albumName
            chosenSong.spotImageData = song.artImageData
            chosenSong.spotSongDuration = Double(song.durationInMillis/1000)
            chosenSong.discNumber = song.disc_number!
            chosenSong.spotPreviewURL = song.previewURL
            chosenSong.songAddedUsing = "Spotify"
            if networkMonitor.isConnected{
                print("Checking network & credentials before getSpotAlbum...")
                print(spotifyAuth.access_Token)
                if !spotifyAuth.access_Token.isEmpty {print("Going to get album");getSpotAlbum()}
                else {getSpotCredentials{_ in print("Getting credentials, then album");getSpotAlbum()}}
            }
            else{showFailedConnectionAlert = true}
        }
        if appDelegate.musicSub.type == .Apple {
            chosenSong.id = song.id
            chosenSong.name = song.name
            chosenSong.artistName = song.artistName
            chosenSong.songAlbumName = song.albumName
            chosenSong.songPreviewURL = song.previewURL
            chosenSong.artwork = song.artImageData
            chosenSong.durationInSeconds = Double(song.durationInMillis/1000)
            chosenSong.discNumber = song.disc_number!
            chosenSong.songAddedUsing = "Apple"
            if networkMonitor.isConnected{getAlbum(storeFront: amAPI.storeFrontID!, userToken: amAPI.taskToken!)}
            else{showFailedConnectionAlert = true}
            showAPV = true
        }
    }
    
    func getSpotAlbum() {
        print("CheckPoint1")
        var cleanAlbumName = String()
        var artistsInAlbumName = String()
        cleanAlbumName = cleanMusicData.compileMusicString(songOrAlbum: chosenSong.songAlbumName, artist: nil, removeList: appDelegate.songFilterForSearch)
        var albumArtistList: [String] = []
        let pageSize = 50
        let totalAlbums = 150
        let totalOffsets = totalAlbums / pageSize
        let group1 = DispatchGroup()
        print("CheckPoint2")
        for offset in 0..<totalOffsets {
            group1.enter()
            print("CheckPoint3")
            DispatchQueue.global().async {
                SpotifyAPI().getAlbumIDUsingNameOnly(albumName: cleanAlbumName, offset: offset * pageSize, authToken: spotifyAuth.access_Token) { albumResponse, error in
                    print("FFFFF")
                    print(spotifyAuth.access_Token)
                    print("CheckPoint4")

                    if let error = error as? URLError, error.code == .notConnectedToInternet {
                        showFailedConnectionAlert = true
                    }
                    
                    if let albumResponse = albumResponse {
                        let group2 = DispatchGroup()

                        for album in albumResponse {
                            print("CheckPoint5")
                            print("Current Album...\(album.name)")
                            group2.enter()

                            DispatchQueue.global().async {
                                SpotifyAPI().getAlbumTracks(albumId: album.id, authToken: spotifyAuth.access_Token) { response, error in
                                    if let trackList = response {
                                        for track in trackList {
                                            print("----Track \(track.name)")
                                            if chosenSong.spotName == track.name {
                                                var allArtists = String()
                                                if album.artists.count > 1 {
                                                    for artist in album.artists { allArtists = allArtists + " " + artist.name}
                                                } else {
                                                    allArtists = album.artists[0].name
                                                }
                                                print("Appended...\(allArtists)")
                                                albumArtistList.append(allArtists)
                                            }
                                        }
                                        print("All tracks in \(album) looped through")
                                    }

                                    // Release the semaphore when getAlbumTracks is finished

                                    group2.leave()
                                }
                            }
                        }

                        group2.notify(queue: DispatchQueue.global()) {
                            group1.leave()
                        }
                    } else {group1.leave()
                    }
                }
            }
            print("Album Group Complete of \(totalOffsets)")
        }

        group1.notify(queue: DispatchQueue.main) {
            var foundMatch = false
            let words = cleanMusicData.cleanMusicString(input: chosenSong.spotArtistName, removeList:appDelegate.songFilterForSearch).components(separatedBy: " ")
            print("notified")
            for artistGroup in albumArtistList {
                for word in words {
                    if artistGroup.contains(word) {
                        print("contains word called")
                        print(artistGroup)
                        chosenSong.spotAlbumArtist = artistGroup
                        foundMatch = true
                        showSPV = true
                        break
                    }
                }
                if foundMatch { break }
            }

            if !foundMatch {
                print("called !foundMatch")
                chosenSong.spotAlbumArtist = albumArtistList[0]
                chosenSong.spotAlbumArtist = albumArtistList.first ?? ""
                showSPV = true
            }
        }
    }

    func getAlbum(storeFront: String, userToken: String) {
        var albumAndArtistForSearch = cleanMusicData.compileMusicString(songOrAlbum: chosenSong.songAlbumName, artist: chosenSong.artistName, removeList: appDelegate.songFilterForSearch)
        var albumForSearch = cleanMusicData.compileMusicString(songOrAlbum: chosenSong.songAlbumName, artist: nil, removeList: appDelegate.songFilterForSearch)
        var songFound = false
        var albumArtistList: [String] = []
        SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
            print("{{{{"); print(albumAndArtistForSearch)
            let group1 = DispatchGroup()
            group1.enter()
            DispatchQueue.global().async {
                AppleMusicAPI().searchForAlbum(albumAndArtist: albumAndArtistForSearch, storeFrontID: storeFront, offset: nil, userToken: userToken, completion: { (response, error) in
                    if response != nil {
                        print("Album Search Response....")
                        if let albumList = response?.results.albums.data {
                            print("# of Albums in Response: \(albumList.count)")
                            let group2 = DispatchGroup()
                        outerLoop: for album in albumList {
                            print("Album Object: "); print(album)
                            group2.enter()
                            DispatchQueue.global().async {
                                AppleMusicAPI().getAlbumTracks(albumId: album.id, storefrontId: storeFront, userToken: userToken, completion: { (response, error) in
                                    if response != nil {
                                        if let trackList = response?.data {
                                            for track in trackList {
                                                print("--- \(chosenSong.artistName)")
                                                print(track.attributes.artistName)
                                                if chosenSong.name == track.attributes.name && songFound == false {
                                                    print("Weak Check - Found Song on Album:")
                                                    print(track.attributes.name)
                                                    print(album.attributes.artistName)
                                                    albumArtistList.append(album.attributes.artistName)
                                                }}}
                                        group2.leave()
                                    }})}}
                            group2.notify(queue: DispatchQueue.global()) {group1.leave()}
                        } else {group1.leave()}
                        group1.notify(queue: DispatchQueue.main) {
                            var foundMatch = false;print("notified")
                            let words = cleanMusicData.cleanMusicString(input: chosenSong.artistName, removeList:appDelegate.songFilterForSearch).components(separatedBy: " ")
                            for artistGroup in albumArtistList {
                                print(artistGroup)
                                print("The Words...")
                                print(words)
                                for word in words {
                                    if artistGroup.contains(word) && songFound == false {
                                        print("Strong Check - Found Match:")
                                        print(artistGroup)
                                        chosenSong.appleAlbumArtist = artistGroup
                                        foundMatch = true; break
                                    }
                                }
                                if foundMatch { break }
                            }
                            if !foundMatch {
                                print("called !foundMatch")
                                chosenSong.appleAlbumArtist = albumArtistList[0]
                                chosenSong.appleAlbumArtist = albumArtistList.first ?? ""
                            }}}
                    else {
                        print("Error when searching with Album + Artist..."); print(error?.localizedDescription)
                        AppleMusicAPI().searchForAlbum(albumAndArtist: albumForSearch, storeFrontID: storeFront, offset: nil, userToken: userToken, completion: { (response, error) in
                            if response != nil {
                                print("Album Search Response....")
                                if let albumList = response?.results.albums.data {
                                    print("# of Albums in Response: \(albumList.count)")
                                    for album in albumList {
                                        print("Album Object: \(album)")
                                        AppleMusicAPI().getAlbumTracks(albumId: album.id, storefrontId: storeFront, userToken: userToken, completion: { (response, error) in
                                            if response != nil {
                                                if let trackList = response?.data {
                                                    for track in trackList {
                                                        if chosenSong.name == track.attributes.name {
                                                            print("Found Song on Album:")
                                                            print(track.attributes.name)
                                                            chosenSong.appleAlbumArtist = album.attributes.artistName
                                                            break
                                                        }}}}})}}}
                            else {print("Error When Searching with Just Album Name"); print(error?.localizedDescription)
                            }})
                    }
                })}}}}
    

    

    
    func getSpotToken(completion: @escaping (Bool) -> Void) {
        print("called....requestSpotToken")
        tokenCounter = 1
        spotifyAuth.auth_code = authCode!
        SpotifyAPI().getToken(authCode: authCode!, completionHandler: {(response, error) in
            if let response = response {
                DispatchQueue.main.async {
                    spotifyAuth.access_Token = response.access_token
                    spotifyAuth.refresh_Token = response.refresh_token
                    defaults.set(response.access_token, forKey: "SpotifyAccessToken")
                    defaults.set(response.refresh_token, forKey: "SpotifyRefreshToken")
                    completion(true)
                }
            } else if let error = error {
                print("Error... \(error.localizedDescription)!")
                invalidAuthCode = true
                authCode = ""
                completion(false)
            }
        })
    }

    func getSpotTokenViaRefresh(completion: @escaping (Bool) -> Void) {
        print("called....requestSpotTokenViaRefresh")
        tokenCounter = 1
        spotifyAuth.auth_code = authCode!
        refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
        SpotifyAPI().getTokenViaRefresh(refresh_token: refresh_token!, completionHandler: {(response, error) in
            if let response = response {
                DispatchQueue.main.async {
                    spotifyAuth.access_Token = response.access_token
                    defaults.set(response.access_token, forKey: "SpotifyAccessToken")
                    completion(true)
                }
            } else if let error = error {
                print("Error... \(error.localizedDescription)!")
                invalidAuthCode = true
                authCode = ""
                completion(false)
            }
        })
    }

    func requestAndRunToken(authType: String, completion: @escaping (Bool) -> Void) {
        print("called....requestSpotAuth")
        invalidAuthCode = false
        SpotifyAPI().requestAuth { response, error in
            guard let response = response else {
                // handle error
                print(error ?? "Unknown error")
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                print("ccccccc")
                print(response)
                
                spotifyAuth.authForRedirect = response
                showWebView = true
                
                refreshAccessToken = true
                
                if authType == "code", !authCode!.isEmpty {
                    getSpotToken { success in
                        completion(success)
                    }
                } else if authType == "refresh_token", !refresh_token!.isEmpty {
                    getSpotTokenViaRefresh { success in
                        completion(success)
                    }
                } else if authCode == "AuthFailed" {
                    print("Unable to authorize")
                    appDelegate.musicSub.type = .Neither
                    showSpotAuthFailedAlert = true
                    completion(false)
                }
            }
        }
    }

    
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    func runInstantiateAppRemote() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if instantiateAppRemoteCounter == 0 {if spotifyAuth.access_Token != "" {instantiateAppRemote()}}
        }
    }
    
    func instantiateAppRemote() {
        instantiateAppRemoteCounter = 1
        DispatchQueue.main.async {
            appRemote2 = SPTAppRemote(configuration: config, logLevel: .debug)
            appRemote2?.connectionParameters.accessToken = spotifyAuth.access_Token
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
                    else{spotifyAuth.authForRedirect = response!;showWebView = true}
                    refreshAccessToken = true
                }}})
    }
    
    func getSpotCredentials(completion: @escaping (Bool) -> Void) {
        print("Run1")
        if defaults.object(forKey: "SpotifyAuthCode") != nil && counter == 0 {
            print("Run2")
            refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
            refreshAccessToken = true
            if networkMonitor.isConnected {
                getSpotTokenViaRefresh { success in
                    if success {
                        counter += 1
                        runInstantiateAppRemote()
                        completion(true)
                    } else {
                        showFailedConnectionAlert = true
                        completion(false)
                    }
                }
            } else {
                showFailedConnectionAlert = true
                completion(false)
            }
        } else {
            print("Run3")
            if networkMonitor.isConnected {
                requestAndRunToken(authType: "code") { success in
                    if success {
                        runInstantiateAppRemote()
                        completion(true)
                    } else {
                        showFailedConnectionAlert = true
                        completion(false)
                    }
                }
            } else {
                showFailedConnectionAlert = true
                completion(false)
            }
        }
    }


    
    
    
    
    func searchWithSpotify() {
        print("searchWithSpotifyCalled...")
        print(spotifyAuth.access_Token)
        if spotifyAuth.access_Token == "" || spotifyAuth.access_Token == nil {isLoading = true; getSpotCredentials{success in performSPOTSearch()}}
        else {performSPOTSearch()}
    }
    
    
    func performSPOTSearch() {
        
        
        let songTerm = cleanMusicData.cleanMusicString(input: self.songSearch, removeList: appDelegate.songFilterForSearch)
        let artistTerm = cleanMusicData.cleanMusicString(input: self.artistSearch, removeList: appDelegate.songFilterForSearch)

        
        SpotifyAPI().searchSpotify(songTerm, artistName: artistTerm, authToken: spotifyAuth.access_Token, completionHandler: {(response, error) in
            
            //if let error = error as? URLError, error.code == .notConnectedToInternet {
            //    showFailedConnectionAlert = true
            //}
            
            if response != nil {
                searchResults = []
                DispatchQueue.main.async {
                    for song in response! {
                        let artURL = URL(string:song.album!.images[2].url)
                        let _ = getURLData(url: artURL!, completionHandler: {(artResponse, error2) in
                            let blankString: String? = ""
                            var songPrev: String?
                            if song.preview_url != nil {songPrev = song.preview_url}
                            else {songPrev = blankString}
                            
                            var allArtists = String()
                            if song.artists.count > 1 {
                                for (index, artist) in song.artists.enumerated() {
                                    if index != 0 {
                                        if song.name.lowercased().contains(artist.name.lowercased()) {}
                                        else {allArtists = allArtists + " & " + artist.name}
                                    }
                                    else {allArtists = artist.name}
                                }
                                
                            }
                            else {allArtists = song.artists[0].name}
                            let songForList = SongForList(id: song.id, name: song.name, artistName: allArtists, albumName: song.album!.name, artImageData: artResponse!, durationInMillis: song.duration_ms, isPlaying: false, previewURL: songPrev!, disc_number: song.disc_number)
                            if song.restrictions?.reason == nil {
                                //if containsString(listOfSubStrings: songKeyWordsToFilterOut, songName: songForList.name) || containsString(listOfSubStrings: songKeyWordsToFilterOut, songName: songForList.albumName) || song.album?.album_type == "single" {
                                if cleanMusicData.containsString(listOfSubStrings: appDelegate.songFilterForSearch, songName: songForList.name) || cleanMusicData.containsString(listOfSubStrings: appDelegate.songFilterForSearch, songName: songForList.albumName) {
                                    print("Contains prohibited substring")
                                }
                                else{searchResults.append(songForList)}
                            }
                        })
                    }}}; if response != nil {print("No Response!")}
                        else{debugPrint(error?.localizedDescription)}
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
            
