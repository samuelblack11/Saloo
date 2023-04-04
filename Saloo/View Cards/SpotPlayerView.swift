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
    @State var songAlbumName: String?
    @State var songArtImageData: Data?
    @State var songDuration: Double?
    @State var songPreviewURL: String?
    @State private var songProgress = 0.0
    @State private var isPlaying = true
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
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
            SpotPlayerView2
            .onAppear{
                if accessedViaGrid {
                    if appDelegate.musicSub.type == .Spotify {
                        print("Run1")
                        if defaults.object(forKey: "SpotifyAuthCode") != nil && counter == 0 {
                            print("Run2")
                            print(defaults.object(forKey: "SpotifyAuthCode") as? String)
                            authCode = defaults.object(forKey: "SpotifyAuthCode") as? String
                            refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
                            refreshAccessToken = true
                            runGetToken(authType: "refresh_token")
                            counter += 1
                        }
                        else{print("Run3");requestSpotAuth(); runGetToken(authType: "code")}
                        runInstantiateAppRemote()
                    }
                }
                print("^^^\(songArtImageData)")
                if (songArtImageData != nil) {playSong()}
                //playSong()
            }
            .onDisappear{appRemote2?.playerAPI?.pause()}
            .navigationBarItems(leading:Button {appDelegate.chosenGridCard = nil
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
        VStack {
                   //if showProgressView {ProgressView().progressViewStyle(.circular) .tint(.green)}
                if songArtImageData != nil {Image(uiImage: UIImage(data: songArtImageData!)!) }
                    Text(songName!)
                        .font(.headline)
                    Text(songArtistName!)
                    HStack {
                        Button {
                            songProgress = 0.0
                            appRemote2?.playerAPI?.skip(toPrevious: defaultCallback)
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
    
    
    // Apple Song ->
    
    
    
    func cleanAMSongForSPOTComparison() -> String {
        var AMString = String()
        var cleanSongName = String()
        var cleanSongArtistName = songArtistName!
                                            .replacingOccurrences(of: ",", with: "")
                                            .replacingOccurrences(of: "&", with: "")
                                            
        var artistsInSongName = String()
        if songName!.contains("(feat.") {
            let songComponents = songName!.components(separatedBy: "(feat.")
            cleanSongName = songComponents[0]
            artistsInSongName = songComponents[1].components(separatedBy: ")")[0]
            artistsInSongName = artistsInSongName.replacingOccurrences(of: "&", with: "")
            if songComponents[1].components(separatedBy: ")").count > 1 {
                let cleanSongNamePt2 = songComponents[1].components(separatedBy: ")")[1]
                cleanSongName = cleanSongName + " " + cleanSongNamePt2
            }
        }
        else {cleanSongName = songName! + " "}
        AMString = (cleanSongName + cleanSongArtistName + artistsInSongName).replacingOccurrences(of: "  ", with: " ")
        print("AMString....")
        print(AMString.withoutPunc)
        return AMString.withoutPunc
    }
    
    
    func cleanSPOTSongForAMComparison(spotSongName: String, spotSongArtist: String) -> String {
        var AMString = String()
        var cleanSongName = String()
        var artistsInSongName = String()
        if spotSongName.contains("(feat.") {
            let songComponents = spotSongName.components(separatedBy: "(feat.")
            cleanSongName = songComponents[0]
            artistsInSongName = songComponents[1].components(separatedBy: ")")[0]
            artistsInSongName = artistsInSongName.replacingOccurrences(of: "&", with: "")
            if songComponents[1].components(separatedBy: ")").count > 1 {
                let cleanSongNamePt2 = songComponents[1].components(separatedBy: ")")[1]
                cleanSongName = cleanSongName + " " + cleanSongNamePt2
            }
        }
        else {cleanSongName = spotSongName}
        var SPOTString = cleanSongName + " " + spotSongArtist.replacingOccurrences(of: ",", with: "")
        SPOTString = SPOTString.withoutPunc
                        .replacingOccurrences(of: "   ", with: " ")
                        .replacingOccurrences(of: "  ", with: " ")
        return SPOTString.withoutPunc
    }
    
    
    
    func getSongViaSpot() {
        SpotifyAPI().searchSpotify(songAlbumName!, authToken: spotifyAuth.access_Token,completionHandler: {(response, error) in
            let searchTerm = cleanAMSongForSPOTComparison()
             print("You Searched \(songAlbumName!)")
            if response != nil {
                DispatchQueue.main.async {
                    for song in response! {
                        var allArtists = String()
                        if song.artists.count > 1 {for artist in song.artists { allArtists = allArtists + " " + artist.name}}
                        else {allArtists = song.artists[0].name}
                        levDistances.append(levenshteinDistance(s1: searchTerm, s2: cleanSPOTSongForAMComparison(spotSongName: song.name, spotSongArtist: allArtists)))
                    }
                    
                    if levDistances.min()! < 6 {
                        let closestMatch = response![levDistances.firstIndex(of: levDistances.min()!)!]
                        print("SSSSS")
                        print(closestMatch)
                        let artURL = URL(string:closestMatch.album.images[2].url)
                        let _ = getURLData(url: artURL!, completionHandler: {(artResponse, error2) in
                            songID = closestMatch.id
                            songArtImageData = artResponse!
                            songDuration = Double(closestMatch.duration_ms) * 0.001
                            songPreviewURL = closestMatch.preview_url
                            playSong()
                            updateRecordWithNewSPOTData(spotID: closestMatch.id, songArtImageData: artResponse!, songDuration: String(Double(closestMatch.duration_ms) * 0.001), songPreviewURL: closestMatch.preview_url!)
                        })}
                    else if songPreviewURL != nil {
                        // show preview player with AMpreview
                        print("No matches within acceptable range, play preview instead")
                    }
                    else {
                        // show alert that song has no preview and cannot be matched to reecipient's subscription.
                    }}}
            else{debugPrint(error?.localizedDescription)}
        })
    }
    

    
    
    
    
    
    
    
    
    func updateRecordWithNewSPOTData(spotID: String, songArtImageData: Data, songDuration: String, songPreviewURL: String) {
        let controller = PersistenceController.shared
        let taskContext = controller.persistentContainer.newTaskContext()
        let ckContainer = PersistenceController.shared.cloudKitContainer
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        print("????")
        controller.updateRecordWithSpotData(for: coreCard!, in: taskContext, with: ckContainer.privateCloudDatabase, spotID: spotID, spotImageData: songArtImageData, spotPreviewURL: songPreviewURL, spotSongDuration: songDuration, completion: { (error) in
            print("Updated Record...")
            print(error)
        } )
    }
    
    
    
    
    
    func playSong() {
        print("Playlsit & Song IDs....")
        print(songID)
        print("$$$$$$")
        print(appRemote2?.isConnected)
        if appRemote2?.isConnected == false {
            appRemote2?.authorizeAndPlayURI("spotify:track:\(songID!)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {appRemote2?.connect()}
        }
        appRemote2?.playerAPI?.pause(defaultCallback)
        print(appRemote2?.isConnected)
        appRemote2?.playerAPI?.enqueueTrackUri("spotify:track:\(songID!)", callback: defaultCallback)
        appRemote2?.playerAPI?.play("spotify:track:\(songID!)", callback: defaultCallback)
        isPlaying = true
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
                    if songID == nil {getSongViaSpot()}
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
        print(songArtImageData)
        tokenCounter = 1
        spotifyAuth.auth_code = authCode!
        refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
        SpotifyAPI().getTokenViaRefresh(refresh_token: refresh_token!, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    spotifyAuth.access_Token = response!.access_token
                    appRemote2?.connectionParameters.accessToken = spotifyAuth.access_Token
                    defaults.set(response!.access_token, forKey: "SpotifyAccessToken")
                    if songID == nil {getSongViaSpot()}
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
    
    func levenshteinDistance(s1: String, s2: String) -> Int {
        let s1Length = s1.count
        let s2Length = s2.count
        var distanceMatrix = [[Int]](repeating: [Int](repeating: 0, count: s2Length + 1), count: s1Length + 1)
        
        for i in 1...s1Length {
            distanceMatrix[i][0] = i
        }
        
        for j in 1...s2Length {
            distanceMatrix[0][j] = j
        }
        
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
    
    
    
    
    
    
    
}

extension String {
    var withoutPunc: String {
        return self.components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: "")
    }
}
