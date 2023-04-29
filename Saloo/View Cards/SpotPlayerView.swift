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
    
    var body: some View {
        SpotPlayerView2
            .onAppear{
                print("SPOT PLAYER APPEARED....")
                if accessedViaGrid && appDelegate.musicSub.type == .Spotify {
                    print("Run1")
                    showProgressView = true
                    if defaults.object(forKey: "SpotifyAuthCode") != nil && counter == 0 {
                        print("Run2")
                        print(defaults.object(forKey: "SpotifyAuthCode") as? String as Any)
                        authCode = defaults.object(forKey: "SpotifyAuthCode") as? String
                        refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
                        refreshAccessToken = true
                        runGetToken(authType: "refresh_token")
                        counter += 1
                    }
                    else{print("Run3");requestSpotAuth(); runGetToken(authType: "code")}
                    runInstantiateAppRemote()
                }
                else{playSong()}
            }
            .onDisappear{
                print("Did view disappear???")
                appRemote2?.playerAPI?.pause()
            }
            .navigationBarItems(leading:Button {chosenCard = nil
            } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
    }
    
    @ViewBuilder var selectButton: some View {
        if confirmButton == true {Button {appRemote2?.playerAPI?.pause();showFCV = true; spotifyAuth.songID = songID!} label: {Text("Select Song For Card").foregroundColor(.blue)}}
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
                        if songProgress < songDuration! && isPlaying {songProgress += 1}
                        if songProgress == songDuration{appRemote2?.playerAPI?.pause()}
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
    }
    
    func cleanAMSongForSPOTComparison() -> String {
        var AMString = String()
        var cleanSongName = removeSubstrings(from: songName!, removeList: appDelegate.songKeyWordsToFilterOut)
        let cleanSongArtistName = songArtistName!
            .replacingOccurrences(of: ",", with: "" )
            .replacingOccurrences(of: " & ", with: " ")
        var artistsInSongName = String()
        
        var featStrings = ["(feat.", "[feat."]
        for featString in featStrings {
            if songName!.contains(featString) {
                let songComponents = songName!.components(separatedBy: featString)
                cleanSongName = songComponents[0]
                artistsInSongName = songComponents[1].components(separatedBy: ")")[0]
                artistsInSongName = artistsInSongName.replacingOccurrences(of: "&", with: "")
                if songComponents[1].components(separatedBy: ")").count > 1 {
                    let cleanSongNamePt2 = songComponents[1].components(separatedBy: ")")[1]
                    cleanSongName = cleanSongName + " " + cleanSongNamePt2
                }
            }
        }
        AMString = (cleanSongName + " " + cleanSongArtistName + artistsInSongName)
        AMString = convertMultipleSpacesToSingleSpace(AMString.withoutPunc.lowercased())
        print("AMString....\(AMString)")
        return AMString
    }
    
    
    func cleanSPOTSongForAMComparison(spotSongName: String, spotSongArtist: String) -> String {
        var SPOTString = String()
        var cleanSongName = removeSubstrings(from: spotSongName, removeList: appDelegate.songKeyWordsToFilterOut)
        let cleanSongArtistName = spotSongArtist
            .replacingOccurrences(of: ",", with: "" )
            .replacingOccurrences(of: " & ", with: " ")
        var artistsInSongName = String()
        var featStrings = ["(feat.", "[feat."]
        for featString in featStrings {
            if spotSongName.contains(featString) {
                let songComponents = spotSongName.components(separatedBy: featString)
                cleanSongName = songComponents[0]
                artistsInSongName = songComponents[1].components(separatedBy: ")")[0]
                artistsInSongName = artistsInSongName.replacingOccurrences(of: "&", with: "")
                if songComponents[1].components(separatedBy: ")").count > 1 {
                    let cleanSongNamePt2 = songComponents[1].components(separatedBy: ")")[1]
                    cleanSongName = cleanSongName + " " + cleanSongNamePt2
                }
            }
        }
        
        SPOTString = (cleanSongName + " " + cleanSongArtistName + artistsInSongName)
        SPOTString = convertMultipleSpacesToSingleSpace(SPOTString.withoutPunc.lowercased())
        print("SPOTString....\(SPOTString)")
        return SPOTString
    }
    
    func removeArtistsFromAlbumName() -> (String, String) {
        var cleanAlbumName = String()
        var artistInAlbumName = String()
        var featStrings = ["(feat.", "[feat."]
        for featString in featStrings {
            print("Contains feat string")
            print(songAlbumName)
            if songAlbumName!.contains(featString) {
                let albumComponents = songAlbumName!.components(separatedBy: featString)
                cleanAlbumName = albumComponents[0]
                artistInAlbumName = albumComponents[1].components(separatedBy: ")")[0]
                artistInAlbumName = artistInAlbumName.replacingOccurrences(of: "&", with: "")
                print(cleanAlbumName)
                print(artistInAlbumName)
                if albumComponents[1].components(separatedBy: ")").count > 1 {
                    let cleanAlbumNamePt2 = albumComponents[1].components(separatedBy: ")")[1]
                    cleanAlbumName = cleanAlbumName + " " + cleanAlbumNamePt2
                    print(cleanAlbumName)
                }
                break
            }
            else {cleanAlbumName = songAlbumName!}
        }
        print("&&&")
        print(cleanAlbumName)
        print(artistInAlbumName)
        return (cleanAlbumName, artistInAlbumName)
    }
    
    func removeSpecialCharacters(from string: String) -> String {
        //    let pattern = "[^a-zA-Z0-9]"
        //    return string.replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
        let allowedCharacters = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"))
        let newString = string.components(separatedBy: allowedCharacters.inverted).joined(separator: "")
        return newString
    }
    
    func getSongViaAlbumSearch() {
        var cleanAlbumNameForURL = (removeArtistsFromAlbumName().0)
        var appleAlbumArtistForURL = removeSpecialCharacters(from: appleAlbumArtist!)
        var foundMatch = false
        let AMString = cleanAMSongForSPOTComparison()
        SpotifyAPI().getAlbumID(albumName: cleanAlbumNameForURL, artistName: appleAlbumArtistForURL , authToken: spotifyAuth.access_Token, completion: { (albums, error) in
            let dispatchGroup = DispatchGroup()
            for album in albums! {
                dispatchGroup.enter()
                print("Got Album...\(album.name)")
                let spotAlbumID = album.id // use the album ID from the current iteration
                SpotifyAPI().searchForAlbum(albumId: spotAlbumID, authToken: spotifyAuth.access_Token) { (albumResponse, error) in
                    if let album = albumResponse {
                        spotImageURL = album.images[2].url
                        SpotifyAPI().getAlbumTracks(albumId: spotAlbumID, authToken: spotifyAuth.access_Token, completion: { (response, error) in
                            for song in response! {
                                // your code here
                                print("Got Track...\(song.name)")
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
                                print(AMString); print("Track Name...."); print(cleanSPOTSongForAMComparison(spotSongName: song.name, spotSongArtist: allArtists))
                                if containsSameWords(AMString, cleanSPOTSongForAMComparison(spotSongName: song.name, spotSongArtist: allArtists)) {
                                    print("SSSSS")
                                    print(song)
                                    let artURL = URL(string: spotImageURL!)
                                    let _ = getURLData(url: artURL!, completionHandler: {(artResponse, error2) in
                                        var allArtists2 = String()
                                        spotName = song.name
                                        spotArtistName = allArtists
                                        songID = song.id
                                        songArtImageData = artResponse!
                                        songDuration = Double(song.duration_ms) * 0.001
                                        playSong()
                                        DispatchQueue.main.async {updateRecordWithNewSPOTData(spotName: song.name, spotArtistName: allArtists2, spotID: song.id, songArtImageData: artResponse!, songDuration: String(Double(song.duration_ms) * 0.001))}
                                    }); foundMatch = true}
                            }
                            dispatchGroup.leave()
                        })}
                    else {dispatchGroup.leave()}
                }
            }
            dispatchGroup.notify(queue: .main) {
                // code to execute after all API calls have finished
                if albums!.count < 1 {
                    if songPreviewURL != nil && foundMatch == false {
                        print("Defer to preview")
                        deferToPreview = true
                        print(deferToPreview)
                        DispatchQueue.main.async {updateRecordWithNewSPOTData(spotName: "LookupFailed", spotArtistName: "LookupFailed", spotID: "LookupFailed", songArtImageData: Data(), songDuration: String(0))}
                    }
                    else { print("Else called to change card type...")
                        //appDelegate.chosenGridCard?.cardType = "noMusicNoGift"
        }}}})}
    
    
    
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
        if appRemote2?.isConnected == false {
            appRemote2?.authorizeAndPlayURI("spotify:track:\(songID!)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {appRemote2?.connect()}
        }
        appRemote2?.playerAPI?.pause(defaultCallback)
        appRemote2?.playerAPI?.enqueueTrackUri("spotify:track:\(songID!)", callback: defaultCallback)
        appRemote2?.playerAPI?.play("spotify:track:\(songID!)", callback: defaultCallback)
        isPlaying = true
        showProgressView = false
    }

}

extension SpotPlayerView {
    
    //func getAuthCodeAndTokenIfExpired() {
    //    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
    //        if invalidAuthCode {requestSpotAuth()}
     //   }
    //}
    
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
                    if songID!.count == 0 {getSongViaAlbumSearch()}
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
                    if songID!.count == 0 {getSongViaAlbumSearch()}
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
            playSong()
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
    
    func convertMultipleSpacesToSingleSpace(_ input: String) -> String {
        let components = input.components(separatedBy: .whitespacesAndNewlines)
        let filtered = components.filter { !$0.isEmpty }
        return filtered.joined(separator: " ")
    }
    
    func containsSameWords(_ str1: String, _ str2: String) -> Bool {
        // Split both strings into arrays of words
        let words1 = str1.split(separator: " ").map { String($0) }
        let words2 = str2.split(separator: " ").map { String($0) }
        // Check if both arrays contain the same set of words
        print("ContainsSameWords is \(Set(words1) == Set(words2))")
        return Set(words1) == Set(words2)
    }
    
    func levenshteinDistance(s1: String, s2: String) -> Int {
        let s1Length = s1.count
        let s2Length = s2.count
        var distanceMatrix = [[Int]](repeating: [Int](repeating: 0, count: s2Length + 1), count: s1Length + 1)
        for i in 1...s1Length {distanceMatrix[i][0] = i}
        for j in 1...s2Length {distanceMatrix[0][j] = j}
        for i in 1...s1Length {
            for j in 1...s2Length {
                let cost = s1[s1.index(s1.startIndex, offsetBy: i - 1)] == s2[s2.index(s2.startIndex, offsetBy: j - 1)] ? 0 : 1
                distanceMatrix[i][j] = min(
                    distanceMatrix[i - 1][j] + 1,
                    distanceMatrix[i][j - 1] + 1,
                    distanceMatrix[i - 1][j - 1] + cost
                )
            }
        }
        return distanceMatrix[s1Length][s2Length]
    }
    
    func removeSubstrings(from string: String, removeList: [String]) -> String {
        var result = string
        for substring in removeList {
            result = result.lowercased().replacingOccurrences(of: substring, with: "")
            result = result.capitalized
        }
        return result
    }
    
}

extension String {
    var withoutPunc: String {
        return self.components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: "")
    }
}
