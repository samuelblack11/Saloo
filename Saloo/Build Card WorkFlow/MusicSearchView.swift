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
    //@State private var storeFrontID = "us"
    @State private var userToken = ""
    @State private var searchResults: [SongForList] = []
    @EnvironmentObject var giftCard: GiftCard
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @ObservedObject var spotifyManager = SpotifyManager.shared
    let cleanMusicData = CleanMusicData()
    @ObservedObject var gettingRecord = GettingRecord.shared
    @State private var player: AVPlayer?
    @State private var showAPV = false
    @State private var showMusicSearchActivity = false
    @State private var showSPV = false
    @State private var showWebView = false
    @State private var isPlaying = false
    @State private var songProgress = 0.0
    @EnvironmentObject var sceneDelegate: SceneDelegate
    //@StateObject var spotifyAuth = SpotifyAuth()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var tokenCounter = 0
    @State private var authCode: String? = ""
    @State private var refresh_token: String? = ""
    @State private var invalidAuthCode = false
    let defaults = UserDefaults.standard
    @State var counter = 0
    @State var refreshAccessToken = false
    @State private var ranAMStoreFront = false
    @State var amAPI = AppleMusicAPI()
    @State private var showSpotAuthFailedAlert = false
    let sortOptions = ["Track", "Artist","Album"]
    @State private var sortByValue = "Track"
    @State var emptyCard: CoreCard? = CoreCard()
    @State var deferToPreview = false
    @State private var isLoading = false
    @Environment(\.colorScheme) var colorScheme

    
    @ObservedObject var alertVars = AlertVars.shared
    @EnvironmentObject var appState: AppState
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
                    VStack {
                        TextField("Track", text: $songSearch)
                        TextField("Artist", text: $artistSearch)
                        Button("Search"){
                            if networkMonitor.isConnected {searchWithSpotify()}
                            else {
                                alertVars.alertType = .failedConnection
                                alertVars.activateAlert = true
                            }
                        }
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
                        else {
                            alertVars.alertType = .failedConnection
                            alertVars.activateAlert = true
                        }
                    }).padding(.top, 15)
                }
                LoadingOverlay()
            }
                NavigationView {
                    ZStack {
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
                                .onTapGesture {isLoading = true ; print("Playing \(song.name)");createChosenSong(song: song)}
                            }
                        }
                        if isLoading {
                            ProgressView().frame(width: UIScreen.screenWidth/2,height: UIScreen.screenHeight/2)
                                .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .dark ? .white : appDelegate.appColor))
                                .scaleEffect(2)
                        }
                    }
                }
                .onAppear{
                    if appDelegate.musicSub.type == .Spotify {getSpotCredentials{success in
                        print("Got SPOT Credentials...\(success)")
                        print(spotifyManager.access_token)
                    }}
                    if appDelegate.musicSub.type == .Apple {
                        if networkMonitor.isConnected {getAMUserTokenAndStoreFront{}}
                        else {
                            alertVars.alertType = .failedConnection
                            alertVars.activateAlert = true}}
                }
                .navigationBarItems(leading:Button {appState.currentScreen = .buildCard([.writeNoteView])} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
                .popover(isPresented: $showAPV) {AMPlayerView(songID: chosenSong.id, songName: chosenSong.name, songArtistName: chosenSong.artistName, songArtImageData: chosenSong.artwork, songDuration: chosenSong.durationInSeconds, songPreviewURL: chosenSong.songPreviewURL, confirmButton: true, chosenCard: $emptyCard, deferToPreview: $deferToPreview, showAPV: $showAPV, isLoading: $isLoading)
                        .presentationDetents([.fraction(0.4)])
                }
                .popover(isPresented: $showSPV) {SpotPlayerView(songID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songArtImageData: chosenSong.spotImageData, songDuration: chosenSong.spotSongDuration, songPreviewURL: chosenSong.spotPreviewURL, confirmButton: true, accessedViaGrid: false, chosenCard: $emptyCard, deferToPreview: $deferToPreview, showSPV: $showSPV, isLoading: $isLoading)
                        .presentationDetents([.fraction(0.4)])
                }
                .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType, alertDismissAction: {
                // code to dismiss your view
                showAPV = false
                }))
            //environmentObject(spotifyAuth)
            .sheet(isPresented: $showWebView){WebVCView(authURLForView: spotifyManager.authForRedirect, authCode: $authCode)}
        }
        //.environmentObject(spotifyAuth)
    }

}

extension MusicSearchView {
    
    func searchWithAM() {
        if amAPI.storeFrontID == nil {isLoading = true; getAMUserTokenAndStoreFront{performAMSearch()}}
        else {performAMSearch()}
    }
    
    func getSpotCredentials(completion: @escaping (Bool) -> Void) {
        if networkMonitor.isConnected {
            if let refreshToken = defaults.object(forKey: "SpotifyRefreshToken") as? String, counter == 0 {refreshTokenAndRun(completion: completion)}
            else {requestAndRunToken(completion: completion)}
        } else {
            alertVars.alertType = .failedConnection
            alertVars.activateAlert = true
            completion(false)
        }
    }
    
    func refreshTokenAndRun(completion: @escaping (Bool) -> Void) {
        refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
        SpotifyAPI.shared.getTokenViaRefresh(refresh_token: refresh_token!) { response, error in
            if let response = response {
                spotifyManager.access_token = response.access_token
                defaults.set(response.access_token, forKey: "SpotifyAccessToken")
                completion(true)
            } else {
                alertVars.alertType = .failedConnection
                alertVars.activateAlert = true
                completion(false)
            }
        }
    }
    
    
    func getSpotToken(completion: @escaping (Bool) -> Void) {
        tokenCounter = 1
        spotifyManager.auth_code = authCode!
        if let authCode = authCode {
            SpotifyAPI.shared.getToken(authCode: spotifyManager.auth_code) { response, error in
                if let response = response {
                    spotifyManager.access_token = response.access_token
                    spotifyManager.appRemote?.connectionParameters.accessToken = spotifyManager.access_token
                    spotifyManager.refresh_token = response.refresh_token
                    defaults.set(response.access_token, forKey: "SpotifyAccessToken")
                    defaults.set(response.refresh_token, forKey: "SpotifyRefreshToken")
                    completion(true)
                } else {
                    invalidAuthCode = true
                    //authCode = ""
                    spotifyManager.auth_code = ""
                    completion(false)
                }
            }
        }
    }
    
    
    
    
    

    func getSpotTokenViaRefresh(completion: @escaping (Bool) -> Void) {
        print("called....requestSpotTokenViaRefresh")
        tokenCounter = 1
        spotifyManager.auth_code = authCode!
        refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
        SpotifyAPI.shared.getTokenViaRefresh(refresh_token: refresh_token!, completionHandler: {(response, error) in
            if let response = response {
                DispatchQueue.main.async {
                    spotifyManager.access_token = response.access_token
                    spotifyManager.appRemote?.connectionParameters.accessToken = spotifyManager.access_token
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

    func requestAndRunToken(completion: @escaping (Bool) -> Void) {
        SpotifyAPI.shared.requestAuth { response, error in
            guard let response = response else {
                completion(false)
                return
            }
            spotifyManager.authForRedirect = response
            showWebView = true
            getSpotToken { success in
                if success {
                    
                    completion(true)
                } else {
                    alertVars.alertType = .failedConnection
                    alertVars.activateAlert = true
                    completion(false)
                }
            }
        }
    }

    
    func getSpotAlbum() {
        print("CheckPoint1")
        var cleanAlbumName = String()
        var artistsInAlbumName = String()
        cleanAlbumName = cleanMusicData.compileMusicString(songOrAlbum: chosenSong.songAlbumName, artist: nil, removeList: appDelegate.songFilterForSearchRegex)
        var albumArtistList: [String] = []
        let pageSize = 50
        let totalAlbums = 150
        let totalOffsets = totalAlbums / pageSize
        let group1 = DispatchGroup()
        print("CheckPoint2")
        print(cleanAlbumName)
        for offset in 0..<totalOffsets {
            group1.enter()
            print("CheckPoint3")
            DispatchQueue.global().async {
                SpotifyAPI.shared.getAlbumIDUsingNameOnly(albumName: cleanAlbumName, offset: offset * pageSize, authToken: spotifyManager.access_token) { albumResponse, error in
                    print("CheckPoint4")
                    print("albumName: \(cleanAlbumName), offset: \(offset * pageSize), authToken: \(spotifyManager.access_token)")
                    print(albumResponse)
                    print("---")
                    print(error)
                    if let error = error as? URLError, error.code == .notConnectedToInternet {
                        alertVars.alertType = .failedConnection
                        alertVars.activateAlert = true
                    }
                    if let albumResponse = albumResponse {
                        let group2 = DispatchGroup()
                        for album in albumResponse {
                            group2.enter()
                            print("CheckPoint5")
                            print("Current Album...\(album.name)")
                            DispatchQueue.global().async {
                                SpotifyAPI.shared.getAlbumTracks(albumId: album.id, authToken: spotifyManager.access_token) { response, error in
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
                                    }
                                    // Ensuring group2.leave() is called for each album regardless of whether a match is found or not
                                    group2.leave()
                                }
                            }
                        }
                        group2.notify(queue: DispatchQueue.global()) {
                            group1.leave()
                        }
                    } else {
                        group1.leave()
                    }
                }
            }
            print("Album Group Complete of \(totalOffsets)")
        }

        group1.notify(queue: DispatchQueue.main) {
            var foundMatch = false
            let words = cleanMusicData.cleanMusicString(input: chosenSong.spotArtistName, removeList:appDelegate.songFilterForSearchRegex).components(separatedBy: " ")
            print("notified")
            for artistGroup in albumArtistList {
                for word in words {
                    if artistGroup.contains(word) {
                        print("contains word called")
                        print(artistGroup)
                        chosenSong.spotAlbumArtist = artistGroup
                        foundMatch = true
                        UIApplication.shared.endEditing()
                        showSPV = true
                        isLoading = false
                        isPlaying = false
                        //break
                    }
                }
                if foundMatch { break }
            }
            // Check if albumArtistList is not empty before attempting to access its elements
            if !foundMatch && !albumArtistList.isEmpty {
                print("called !foundMatch")
                chosenSong.spotAlbumArtist = albumArtistList[0]
                chosenSong.spotAlbumArtist = albumArtistList.first ?? ""
                UIApplication.shared.endEditing()
                showSPV = true
                isLoading = false
                isPlaying = false
            }
        }
    }

    func getAlbum(storeFront: String, userToken: String) {
        var albumAndArtistForSearch = cleanMusicData.compileMusicString(songOrAlbum: chosenSong.songAlbumName, artist: chosenSong.artistName, removeList: appDelegate.songFilterForSearchRegex)
        var albumForSearch = cleanMusicData.compileMusicString(songOrAlbum: chosenSong.songAlbumName, artist: nil, removeList: appDelegate.songFilterForSearchRegex)
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
                            let words = cleanMusicData.cleanMusicString(input: chosenSong.artistName, removeList:appDelegate.songFilterForSearchRegex).components(separatedBy: " ")
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

    
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func searchWithSpotify() {
        print("searchWithSpotifyCalled...")
        print(spotifyManager.access_token)
        if spotifyManager.access_token == "" || spotifyManager.access_token == nil {isLoading = true; getSpotCredentials{success in performSPOTSearch()}}
        else {
            print("Else called...")
            performSPOTSearch()
            
            
        }
    }
    
    
    func performSPOTSearch() {
        isLoading = true
        print("!!!")
        print(spotifyManager.access_token)
        let songTerm = cleanMusicData.cleanMusicString(input: self.songSearch, removeList: appDelegate.songFilterForSearchRegex)
        let artistTerm = cleanMusicData.cleanMusicString(input: self.artistSearch, removeList: appDelegate.songFilterForSearchRegex)
        SpotifyAPI.shared.searchSpotify(songTerm, artistName: artistTerm, authToken: spotifyManager.access_token, completionHandler: {(response, error) in
            if response != nil {
                searchResults = []
                DispatchQueue.main.async {
                    for song in response! {
                        print("^^^")
                        print(song)
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
                            let songForList = SongForList(id: song.id, name: song.name, artistName: allArtists, albumName: song.album!.name, artImageData: artResponse!, durationInMillis: song.duration_ms, isPlaying: false, previewURL: songPrev!, disc_number: song.disc_number, url: (song.external_urls?.spotify!)!)
                            if song.restrictions?.reason == nil {
                                //if containsString(listOfSubStrings: songKeyWordsToFilterOut, songName: songForList.name) || containsString(listOfSubStrings: songKeyWordsToFilterOut, songName: songForList.albumName) || song.album?.album_type == "single" {
                                if cleanMusicData.containsString(listOfSubStrings: appDelegate.songFilterForSearchRegex, songName: songForList.name) || cleanMusicData.containsString(listOfSubStrings: appDelegate.songFilterForSearchRegex, songName: songForList.albumName) {
                                    print("Contains prohibited substring")
                                }
                                else{searchResults.append(songForList)}
                            }
                        })
                    }; isLoading = false}}; if response != nil {print("No Response!")}
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
    

    
    func performAMSearch() {
        isLoading = true
        print("---")
        print("isLoading...\(isLoading)");
        SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
            let amSearch = cleanMusicData.cleanMusicString(input: self.songSearch, removeList: appDelegate.songFilterForSearchRegex)
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
                                let songForList = SongForList(id: song.attributes.playParams.id, name: song.attributes.name, artistName: song.attributes.artistName, albumName: song.attributes.albumName,artImageData: artResponse!, durationInMillis: song.attributes.durationInMillis, isPlaying: false, previewURL: songPrev!, disc_number: song.attributes.discNumber, url: song.attributes.url)
                                if cleanMusicData.containsString(listOfSubStrings: appDelegate.songFilterForSearchRegex, songName: songForList.name) || cleanMusicData.containsString(listOfSubStrings: appDelegate.songFilterForSearchRegex, songName: songForList.albumName){
                                print("Did Not Append....")
                                print(songForList.name)
                            }
                            else {searchResults.append(songForList)}
                            })}; isLoading = false}
                }; if response != nil {print("No Response!")}
                else {debugPrint(error?.localizedDescription)}}
            )}}
    }
    
    func createChosenSong(song: SongForList) {

        songProgress = 0.0; isPlaying = true
        if appDelegate.musicSub.type == .Spotify {
            print("Chosen Song URL Is...")
            print(song.url)
            chosenSong.spotID = song.id
            chosenSong.spotName = song.name
            chosenSong.spotArtistName = song.artistName
            chosenSong.songAlbumName = song.albumName
            chosenSong.spotImageData = song.artImageData
            chosenSong.spotSongDuration = Double(song.durationInMillis/1000)
            chosenSong.discNumber = song.disc_number!
            chosenSong.spotPreviewURL = song.previewURL
            chosenSong.songAddedUsing = "Spotify"
            chosenSong.spotSongURL = song.url
            if networkMonitor.isConnected{
                print("Checking network & credentials before getSpotAlbum...")
                print(spotifyManager.access_token)
                if !spotifyManager.access_token.isEmpty {print("Going to get album");getSpotAlbum()}
                else {getSpotCredentials{_ in print("Getting credentials, then album");getSpotAlbum()}}
            }
            else{
                alertVars.alertType = .failedConnection
                alertVars.activateAlert = true
                
            }
        }
        if appDelegate.musicSub.type == .Apple {
            print("Chosen Song URL Is...")
            print(song.url)
            //print(song.external_urls[0]!.spotify)
            chosenSong.id = song.id
            chosenSong.name = song.name
            chosenSong.artistName = song.artistName
            chosenSong.songAlbumName = song.albumName
            chosenSong.songPreviewURL = song.previewURL
            chosenSong.artwork = song.artImageData
            chosenSong.durationInSeconds = Double(song.durationInMillis/1000)
            chosenSong.discNumber = song.disc_number!
            chosenSong.songAddedUsing = "Apple"
            chosenSong.appleSongURL = song.url
            if networkMonitor.isConnected{getAlbum(storeFront: amAPI.storeFrontID!, userToken: amAPI.taskToken!)}
            else{
                alertVars.alertType = .failedConnection
                alertVars.activateAlert = true
                
            }
            UIApplication.shared.endEditing()
            showAPV = true
            isLoading = false
            isPlaying = false
        }
    }
 
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

            
