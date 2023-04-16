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
    @State private var storeFrontID = "us"
    @State private var userToken = ""
    @State private var searchResults: [SongForList] = []
    @EnvironmentObject var giftCard: GiftCard

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
    var songKeyWordsToFilterOut = ["(live","[live","live at","live in","live from"]
    
    
    
    func determineCardType() -> String {
        print("called determineCardType...")
        print(chosenSong.id)
        var cardType2 = String()
        if chosenSong.id != nil && giftCard.id != ""  {cardType2 = "musicAndGift"}
        else if chosenSong.id != nil && giftCard.id == ""  {cardType2 = "musicNoGift"}
        else if chosenSong.id == nil && giftCard.id != ""  {cardType2 = "giftNoMusic"}
        else{cardType2 = "noMusicNoGift"}
        
        return cardType2
        
    }

    var body: some View {
        NavigationStack {
            TextField("Search Songs", text: $songSearch, onCommit: {
                UIApplication.shared.resignFirstResponder()
                if self.songSearch.isEmpty {
                    self.searchResults = []
                } else {
                    switch appDelegate.musicSub.type {
                    case .Apple:
                        return searchWithAM()
                    case .Neither:
                        return searchWithAM()
                    case .Spotify:
                        return searchWithSpotify()
                    }
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
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(song.artistName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Spacer()
                        }
                        .frame(width: UIScreen.screenWidth, height: (UIScreen.screenHeight/7))
                        .onTapGesture {
                            print("Playing \(song.name)")
                            createChosenSong(song: song)
                        }
                    }
                }
            }
            .onAppear{
                if appDelegate.musicSub.type == .Spotify {
                    print("Run1")
                    if defaults.object(forKey: "SpotifyAuthCode") != nil && counter == 0 {
                        print("Run2")
                        refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
                        refreshAccessToken = true
                        runGetToken(authType: "refresh_token")
                        counter += 1
                    }
                    else{print("Run3");requestSpotAuth(); runGetToken(authType: "code")}
                    runInstantiateAppRemote()
                }
                if appDelegate.musicSub.type == .Apple {
                    getAMUserToken()
                    getAMStoreFront()
                }
                
                
            }
            .navigationBarItems(leading:Button {showWriteNote.toggle()} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
            .popover(isPresented: $showAPV) {AMPlayerView(songID: chosenSong.id, songName: chosenSong.name, songArtistName: chosenSong.artistName, songArtImageData: chosenSong.artwork, songDuration: chosenSong.durationInSeconds, songPreviewURL: chosenSong.songPreviewURL, confirmButton: true, showFCV: $showFCV)
                    .presentationDetents([.fraction(0.4)])
                    .fullScreenCover(isPresented: $showFCV) {FinalizeCardView(cardType: determineCardType())}
            }
            .popover(isPresented: $showSPV) {SpotPlayerView(songID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songArtImageData: chosenSong.spotImageData, songDuration: chosenSong.spotSongDuration, songPreviewURL: chosenSong.spotPreviewURL, confirmButton: true, showFCV: $showFCV, accessedViaGrid: false, appRemote2: appRemote2)
                    .presentationDetents([.fraction(0.4)])
                    .fullScreenCover(isPresented: $showFCV) {FinalizeCardView(cardType: determineCardType(), appRemote2: appRemote2)}
                    .fullScreenCover(isPresented: $showWriteNote) {WriteNoteView()}
            }
            .environmentObject(spotifyAuth)
            .sheet(isPresented: $showWebView){WebVCView(authURLForView: spotifyAuth.authForRedirect, authCode: $authCode)}
        }
        .environmentObject(spotifyAuth)
    }

}

extension MusicSearchView {
    
    //func removeSpecialCharacters(from string: String) -> String {
    //    let pattern = "[^a-zA-Z0-9]"
    //    return string.replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
    //}
    
    func removeSpecialCharacters(from string: String) -> String {
        let allowedCharacters = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"))
        let newString = string.components(separatedBy: allowedCharacters.inverted).joined(separator: "")
        return newString
    }
    
    func getAMUserToken() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if amAPI.taskToken == nil {
                SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {amAPI.getUserToken(completionHandler: { ( response, error) in
                    print("Checking Token")
                    print(response)
                    print("^^")
                    print(error)
        })}}}}}

    func getAMStoreFront() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if amAPI.taskToken != nil && ranAMStoreFront == false {
                ranAMStoreFront = true
                SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
                    amAPI.storeFrontID = amAPI.fetchUserStorefront(userToken: amAPI.taskToken!, completionHandler: { ( response, error) in
                        amAPI.storeFrontID = response!.data[0].id
                    })}}}
            }
        }
    func containsString(listOfSubStrings: [String], songName: String) -> Bool {
        let lowercasedInString = songName.lowercased()
        for item in listOfSubStrings {
            if lowercasedInString.range(of: item.lowercased(), options: .caseInsensitive) != nil {
                return true
            }
        }
        return false
    }
    
    func searchWithAM() {
        SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
            self.searchResults = AppleMusicAPI().searchAppleMusic(removeSpecialCharacters(from: self.songSearch), storeFrontID: amAPI.storeFrontID!, userToken: amAPI.taskToken!, completionHandler: { (response, error) in
                if response != nil {
                    DispatchQueue.main.async {
                        for song in response! {
                            
                            let blankString: String? = ""
                            var songPrev: String?
                            if song.attributes.previews.count > 0 {print("it's not nil"); songPrev = song.attributes.previews[0].url}
                            else {songPrev = blankString}
                            
                            
                            print("Search With AM called...")
                            
                            let artURL = URL(string:song.attributes.artwork.url.replacingOccurrences(of: "{w}", with: "80").replacingOccurrences(of: "{h}", with: "80"))
                            let _ = getURLData(url: artURL!, completionHandler: { (artResponse, error2) in
                                
                            let songForList = SongForList(id: song.attributes.playParams.id, name: song.attributes.name, artistName: song.attributes.artistName, albumName: song.attributes.albumName,artImageData: artResponse!, durationInMillis: song.attributes.durationInMillis, isPlaying: false, previewURL: songPrev!)
                            if containsString(listOfSubStrings: songKeyWordsToFilterOut, songName: songForList.name) {
                                print("Did Not Append....")
                                print(songForList.name)
                            }
                            else {searchResults.append(songForList)}
                            })}}}; if response != nil {print("No Response!")}
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
            chosenSong.spotPreviewURL = song.previewURL
            chosenSong.songAddedUsing = "Spotify"
            getSpotAlbum()
            showSPV = true
        }
        if appDelegate.musicSub.type == .Apple {
            chosenSong.id = song.id
            chosenSong.name = song.name
            chosenSong.artistName = song.artistName
            chosenSong.songAlbumName = song.albumName
            chosenSong.songPreviewURL = song.previewURL
            chosenSong.artwork = song.artImageData
            chosenSong.durationInSeconds = Double(song.durationInMillis/1000)
            chosenSong.songAddedUsing = "Apple"
            getAlbum(storeFront: amAPI.storeFrontID!, userToken: amAPI.taskToken!)
            showAPV = true
        }
    }
    
    
    
    func getSpotAlbum() {
        SpotifyAPI().getAlbumIDUsingNameOnly(albumName: removeSpecialCharacters(from: chosenSong.songAlbumName), authToken: spotifyAuth.access_Token, completion: { (response, error) in
            if response != nil {
                for album in response! {
                    print("Got Album Named: ")
                    print(album.name)
                    SpotifyAPI().getAlbumTracks(albumId: album.id, authToken: spotifyAuth.access_Token, completion: {(response, error) in
                        if let trackList = response {
                            for track in trackList {
                                if chosenSong.spotName == track.name {
                                    print("Found Song Name Match on Album Named above...")
                                    var allArtists = String()
                                    if album.artists.count > 1 {for artist in album.artists { allArtists = allArtists + " " + artist.name}}
                                    else {allArtists = album.artists[0].name}
                                    print("Album Artists Are...\(allArtists)")
                                    chosenSong.spotAlbumArtist = allArtists
                                    break
                                }
                }}})}}})}
    
    func getAlbum(storeFront: String, userToken: String) {
        SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
            AppleMusicAPI().searchForAlbum(albumName: removeSpecialCharacters(from: chosenSong.songAlbumName), storeFrontID: storeFront,  userToken: userToken, completion: { (response, error) in
                
                
                
                
                if response != nil {
                    print("Album Search Response....")
                    if let albumList = response?.results.albums.data {
                        print("# of Albums in Response: \(albumList.count)")
                        for album in albumList {
                            print("Album Object: ")
                            print(album)
                            AppleMusicAPI().getAlbumTracks(albumId: album.id, storefrontId: storeFront, userToken: userToken, completion: { (response, error) in
                                if response != nil {
                                    if let trackList = response?.data {
                                        for track in trackList {
                                            if chosenSong.name == track.attributes.name {
                                                print("Found Song on Album:")
                                                print(track.attributes.name)
                                                chosenSong.appleAlbumArtist = album.attributes.artistName
                                                break
                                            }
                                            
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
                else {
                    print("Error...")
                    print(error?.localizedDescription)
                }
        })}}}
    

    
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
    
    func getAuthCodeAndTokenIfExpired() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if invalidAuthCode {requestSpotAuth()}
        }
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
                    showSpotAuthFailedAlert = true
                    
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
        print("called....instantiateAppRemote")
        print(spotifyAuth.access_Token)
        instantiateAppRemoteCounter = 1
        DispatchQueue.main.async {
            appRemote2 = SPTAppRemote(configuration: config, logLevel: .debug)
            appRemote2?.connectionParameters.accessToken = spotifyAuth.access_Token
        }
    }
    
    func searchWithSpotify() {
        SpotifyAPI().searchSpotify(removeSpecialCharacters(from: self.songSearch), authToken: spotifyAuth.access_Token, completionHandler: {(response, error) in
            if response != nil {
                searchResults = []
                DispatchQueue.main.async {
                    for song in response! {
                        print("BBBBB")
                        print(song.restrictions)
                        print(song)
                        let artURL = URL(string:song.album!.images[2].url)
                        let _ = getURLData(url: artURL!, completionHandler: {(artResponse, error2) in
                            let blankString: String? = ""
                            var songPrev: String?
                            if song.preview_url != nil {print("it's not nil"); songPrev = song.preview_url}
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
                            
                            
                            
                            let songForList = SongForList(id: song.id, name: song.name, artistName: allArtists, albumName: song.album!.name, artImageData: artResponse!, durationInMillis: song.duration_ms, isPlaying: false, previewURL: songPrev!)
                            if song.restrictions?.reason == nil {
                                if containsString(listOfSubStrings: songKeyWordsToFilterOut, songName: songForList.name) {
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
            
