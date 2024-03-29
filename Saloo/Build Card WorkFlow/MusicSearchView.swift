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
    @State private var userToken = ""
    @State private var searchResults: [SongForList] = []
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var spotifyManager: SpotifyManager
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
    @State private var hasShownLaunchView: Bool = true
    @State private var currentStep: Int = 4
    @ObservedObject var alertVars = AlertVars.shared
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var cardProgress: CardProgress
    var sortResults: some View {
        HStack {
            Text("Sort By:").padding(.leading, 5).font(Font.custom(sortByValue, size: 12))
            Picker("", selection: $sortByValue) {ForEach(sortOptions, id:\.self) {sortOption in Text(sortOption)}}
            Spacer()
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                CustomNavigationBar(onBackButtonTap: {cardProgress.currentStep = 3; appState.currentScreen = .buildCard([.writeNoteView])}, titleContent: .text("Select Your Song"))
                ProgressBar().frame(height: 20)
                    .frame(height: 20)
                ZStack {
                    if appDelegate.musicSub.type == .Spotify {
                        VStack {
                            TextField("Enter Song Name Here", text: $songSearch)
                            Text("And/Or")
                            TextField("Enter Artist Name Here", text: $artistSearch)
                            HStack{
                                Image("SpotifyIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 24)
                                Button("Search"){
                                    if networkMonitor.isConnected {searchWithSpotify()}
                                    else {
                                        alertVars.alertType = .failedConnection
                                        alertVars.activateAlert = true
                                    }
                                }
                            }
                        }
                    }
                    else {
                        HStack {
                            Button(action: {
                                if let url = URL(string: "music://") {UIApplication.shared.open(url)}
                            }) {
                                Image("AMIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 24)
                                    .padding(.top, 15)
                            }
                            TextField("Search Songs and/or Artists", text: $songSearch, onCommit: {
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
                    }
                    LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
                }
            }
            NavigationView {
                ZStack {
                    List {
                        ForEach(searchResults, id: \.self) { song in
                            HStack {
                                Image(uiImage: UIImage(data: song.artImageData)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 64, height: 64)
                                VStack(alignment: .leading) {
                                    Text(song.name).font(.headline).lineLimit(2)
                                    Text(song.artistName).font(.caption).foregroundColor(.secondary).lineLimit(1)
                                }
                                Spacer()
                            }
                            .onTapGesture {DispatchQueue.main.async {isLoading = true};createChosenSong(song: song)}
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
                    if appDelegate.musicSub.type == .Spotify {
                            spotifyManager.updateCredentialsIfNeeded{success in
                                spotifyManager.verifySubType{isPremium in
                                    if !isPremium {
                                        alertVars.alertType = .spotNeedPremium
                                        alertVars.activateAlert = true
                                        DispatchQueue.main.async {isLoading = false}
                                    }
                                }
                                spotifyManager.noInternet = {
                                    alertVars.alertType = .failedConnection
                                    alertVars.activateAlert = true
                                }
                        }
                    }
                    if appDelegate.musicSub.type == .Apple {
                        if networkMonitor.isConnected {getAMUserTokenAndStoreFront{}}
                        else {
                            alertVars.alertType = .failedConnection
                            alertVars.activateAlert = true}}
                }
                .popover(isPresented: $showAPV) {AMPlayerView(songID: chosenSong.id, songName: chosenSong.name, songArtistName: chosenSong.artistName, songArtImageData: chosenSong.artwork, songDuration: chosenSong.durationInSeconds, songPreviewURL: chosenSong.songPreviewURL, confirmButton: true, chosenCard: $emptyCard, deferToPreview: $deferToPreview, showAPV: $showAPV, isLoading: $isLoading, songURL: chosenSong.appleSongURL)
                        .presentationDetents([.fraction(0.435)])
                }
                .popover(isPresented: $showSPV) {SpotPlayerView(songID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songArtImageData: chosenSong.spotImageData, songDuration: chosenSong.spotSongDuration, songPreviewURL: chosenSong.spotPreviewURL, confirmButton: true, songURL: chosenSong.spotSongURL, accessedViaGrid: false, chosenCard: $emptyCard, deferToPreview: $deferToPreview, showSPV: $showSPV, isLoading: $isLoading)
                        .presentationDetents([.fraction(0.435)])
                }
                .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType, alertDismissAction: {
                showAPV = false
                }))
            .sheet(isPresented: $showWebView){WebVCView(authURLForView: spotifyManager.authForRedirect, authCode: $authCode)}
        }
    }

}

extension MusicSearchView {
    
    func searchWithAM() {
        if amAPI.storeFrontID == nil {DispatchQueue.main.async {isLoading = true}; getAMUserTokenAndStoreFront{performAMSearch()}}
        else {performAMSearch()}
    }

    func getSpotAlbum() {
        var cleanAlbumName = String()
        var artistsInAlbumName = String()
        cleanAlbumName = cleanMusicData.compileMusicString(songOrAlbum: chosenSong.songAlbumName, artist: nil, removeList: appDelegate.songFilterForSearchRegex)
        var albumArtistList: [String] = []
        let pageSize = 50
        let totalAlbums = 150
        let totalOffsets = totalAlbums / pageSize
        let group1 = DispatchGroup()
        print(cleanAlbumName)
        for offset in 0..<totalOffsets {
            group1.enter()
            DispatchQueue.global().async {
                SpotifyAPI.shared.getAlbumIDUsingNameOnly(albumName: cleanAlbumName, offset: offset * pageSize, authToken: spotifyManager.access_token) { albumResponse, error in
                    if let error = error as? URLError, error.code == .notConnectedToInternet {
                        alertVars.alertType = .failedConnection
                        alertVars.activateAlert = true
                    }
                    if let albumResponse = albumResponse {
                        let group2 = DispatchGroup()
                        for album in albumResponse {
                            group2.enter()
                            DispatchQueue.global().async {
                                SpotifyAPI.shared.getAlbumTracks(albumId: album.id, authToken: spotifyManager.access_token) { response, error in
                                    if let trackList = response {
                                        for track in trackList {
                                            if chosenSong.spotName == track.name {
                                                var allArtists = String()
                                                if album.artists.count > 1 {
                                                    for artist in album.artists { allArtists = allArtists + " " + artist.name}
                                                } else {
                                                    allArtists = album.artists[0].name
                                                }
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
        }

        group1.notify(queue: DispatchQueue.main) {
            var foundMatch = false
            let words = cleanMusicData.cleanMusicString(input: chosenSong.spotArtistName, removeList:appDelegate.songFilterForSearchRegex).components(separatedBy: " ")
            for artistGroup in albumArtistList {
                for word in words {
                    if artistGroup.contains(word) {
                        chosenSong.spotAlbumArtist = artistGroup
                        foundMatch = true
                        UIApplication.shared.endEditing()
                        showSPV = true
                        DispatchQueue.main.async {isLoading = false}
                        isPlaying = false
                        //break
                    }
                }
                if foundMatch { break }
            }
            // Check if albumArtistList is not empty before attempting to access its elements
            if !foundMatch && !albumArtistList.isEmpty {
                chosenSong.spotAlbumArtist = albumArtistList[0]
                chosenSong.spotAlbumArtist = albumArtistList.first ?? ""
                UIApplication.shared.endEditing()
                showSPV = true
                DispatchQueue.main.async {isLoading = false}
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
            let group1 = DispatchGroup()
            group1.enter()
            DispatchQueue.global().async {
                AppleMusicAPI().searchForAlbum(albumAndArtist: albumAndArtistForSearch, storeFrontID: storeFront, offset: nil, userToken: userToken, completion: { (response, error) in
                    if response != nil {
                        if let albumList = response?.results.albums.data {
                            let group2 = DispatchGroup()
                        outerLoop: for album in albumList {
                            group2.enter()
                            DispatchQueue.global().async {
                                AppleMusicAPI().getAlbumTracks(albumId: album.id, storefrontId: storeFront, userToken: userToken, completion: { (response, error) in
                                    if response != nil {
                                        if let trackList = response?.data {
                                            for track in trackList {
                                                if chosenSong.name == track.attributes.name && songFound == false {
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
                                for word in words {
                                    if artistGroup.contains(word) && songFound == false {
                                        chosenSong.appleAlbumArtist = artistGroup
                                        foundMatch = true; break
                                    }
                                }
                                if foundMatch { break }
                            }
                            if !foundMatch {
                                chosenSong.appleAlbumArtist = albumArtistList[0]
                                chosenSong.appleAlbumArtist = albumArtistList.first ?? ""
                            }}}
                    else {
                        AppleMusicAPI().searchForAlbum(albumAndArtist: albumForSearch, storeFrontID: storeFront, offset: nil, userToken: userToken, completion: { (response, error) in
                            if response != nil {
                                if let albumList = response?.results.albums.data {
                                    for album in albumList {
                                        AppleMusicAPI().getAlbumTracks(albumId: album.id, storefrontId: storeFront, userToken: userToken, completion: { (response, error) in
                                            if response != nil {
                                                if let trackList = response?.data {
                                                    for track in trackList {
                                                        if chosenSong.name == track.attributes.name {
                                                            chosenSong.appleAlbumArtist = album.attributes.artistName
                                                            break
                                                        }}}}})}}}
                            else {}})
                    }
                })}}}}

    
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func searchWithSpotify() {
        if spotifyManager.access_token == "" || spotifyManager.access_token == nil {DispatchQueue.main.async {isLoading = true}; spotifyManager.updateCredentialsIfNeeded{success in
            spotifyManager.verifySubType{isPremium in
                if !isPremium {
                    alertVars.alertType = .spotNeedPremium
                    alertVars.activateAlert = true
                    DispatchQueue.main.async {isLoading = false}
                }
                else {performSPOTSearch()}}
            }
        }
        else {
            performSPOTSearch()
        }
    }
    
    
    func performSPOTSearch() {
        DispatchQueue.main.async {isLoading = true}
        let songTerm = cleanMusicData.cleanMusicString(input: self.songSearch, removeList: appDelegate.songFilterForSearchRegex)
        let artistTerm = cleanMusicData.cleanMusicString(input: self.artistSearch, removeList: appDelegate.songFilterForSearchRegex)
        SpotifyAPI.shared.searchSpotify(songTerm, artistName: artistTerm, authToken: spotifyManager.access_token, completionHandler: {(response, error) in
            if response != nil {
                searchResults = []
                DispatchQueue.main.async {
                    for song in response! {
                        var artURL: URL? = nil

                        if let imageURL = song.album?.images[safe: 2]?.url {artURL = URL(string: imageURL)}
                        else  {artURL = URL(string: Config.shared.spotArtURL)}
                        
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
                                        else {allArtists = allArtists + ", " + artist.name}
                                    }
                                    else {allArtists = artist.name}
                                }
                                
                            }
                            else {allArtists = song.artists[0].name}
                            var artResponseforSFL = artResponse
                            if let artResponse = artResponse, let image = UIImage(data: artResponse), image.size.width > 64 || image.size.height > 64 {
                                let sideLength: CGFloat = 64
                                if let newImage = image.resizedImageForSquareCanvas(sideLength: sideLength) {
                                    let resizedArtResponse = newImage.jpegData(compressionQuality: 1.0)
                                    artResponseforSFL = resizedArtResponse
                                }
                            }
                            let songForList = SongForList(id: song.id, name: song.name, artistName: allArtists, albumName: song.album!.name, artImageData: artResponseforSFL!, durationInMillis: song.duration_ms, isPlaying: false, previewURL: songPrev!, disc_number: song.disc_number, url: (song.external_urls?.spotify!)!)
                            if song.restrictions?.reason == nil {
                                if cleanMusicData.containsString(listOfSubStrings: appDelegate.songFilterForSearchRegex, songName: songForList.name) || cleanMusicData.containsString(listOfSubStrings: appDelegate.songFilterForSearchRegex, songName: songForList.albumName) {
                                    print("Contains prohibited substring")
                                }
                                else{searchResults.append(songForList)}
                            }
                        })
                    }; DispatchQueue.main.async {isLoading = false}}}; if response != nil {print("No Response!")}
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
        DispatchQueue.main.async {isLoading = true}
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
                            let artURL = URL(string:song.attributes.artwork.url.replacingOccurrences(of: "{w}", with: "80").replacingOccurrences(of: "{h}", with: "80"))
                            let _ = getURLData(url: artURL!, completionHandler: { (artResponse, error2) in
                                let songForList = SongForList(id: song.attributes.playParams.id, name: song.attributes.name, artistName: song.attributes.artistName, albumName: song.attributes.albumName,artImageData: artResponse!, durationInMillis: song.attributes.durationInMillis, isPlaying: false, previewURL: songPrev!, disc_number: song.attributes.discNumber, url: song.attributes.url)
                                if cleanMusicData.containsString(listOfSubStrings: appDelegate.songFilterForSearchRegex, songName: songForList.name) || cleanMusicData.containsString(listOfSubStrings: appDelegate.songFilterForSearchRegex, songName: songForList.albumName){
                            }
                            else {searchResults.append(songForList)}
                            })}; DispatchQueue.main.async {isLoading = false}}
                }; if response != nil {print("No Response!")}
                else {debugPrint(error?.localizedDescription)}}
            )}}
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
            chosenSong.spotSongURL = song.url
            if networkMonitor.isConnected{
                if !spotifyManager.access_token.isEmpty {getSpotAlbum()}
                else {spotifyManager.updateCredentialsIfNeeded{_ in
                    spotifyManager.verifySubType{isPremium in
                        if !isPremium {
                            alertVars.alertType = .spotNeedPremium
                            alertVars.activateAlert = true
                            DispatchQueue.main.async {isLoading = false}
                        }
                        else {getSpotAlbum()}
                    }
                }}
            }
            else{
                alertVars.alertType = .failedConnection
                alertVars.activateAlert = true
                
            }
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
            chosenSong.appleSongURL = song.url
            if networkMonitor.isConnected{getAlbum(storeFront: amAPI.storeFrontID!, userToken: amAPI.taskToken!)}
            else{
                alertVars.alertType = .failedConnection
                alertVars.activateAlert = true
            }
            UIApplication.shared.endEditing()
            showAPV = true
            DispatchQueue.main.async {isLoading = false}
            isPlaying = false
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension UIImage {
    func resizedImageForSquareCanvas(sideLength: CGFloat) -> UIImage? {
        let scale = sideLength / max(size.width, size.height)
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        let origin = CGPoint(x: (sideLength - scaledSize.width) / 2, y: (sideLength - scaledSize.height) / 2)

        UIGraphicsBeginImageContextWithOptions(CGSize(width: sideLength, height: sideLength), false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: origin, size: scaledSize))

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
