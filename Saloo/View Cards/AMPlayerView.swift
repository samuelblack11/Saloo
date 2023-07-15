//
//  AMPlayerView.swift
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
//import CleanMusicData

struct AMPlayerView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var songID: String?
    @State var songName: String?
    @State var songArtistName: String?
    @State var spotName: String?
    @State var spotArtistName: String?
    @State var songAlbumName: String?
    @State var songArtImageData: Data?
    @State var songDuration: Double?
    @State var songPreviewURL: String?
    @State private var songProgress = 0.0
    @State private var isPlaying = true
    @State var confirmButton: Bool
    @State private var player: AVPlayer?
    @State private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @Environment(\.presentationMode) var presentationMode
    var amAPI = AppleMusicAPI()
    @State private var ranAMStoreFront = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var fromFinalize = false
    @State var showGrid = false
    @State var coreCard: CoreCard?
    @State var accessedViaGrid = true
    //@State var whichBoxVal: InOut.SendReceive = .inbox
    @State var appleAlbumArtist: String?
    @State var spotAlbumArtist: String?
    @State var levDistances: [Int] = []
    //@State var foundMatch = "isSearching"
    @State var breakTrigger1 = false
    @Binding var chosenCard: CoreCard?
    @Binding var deferToPreview: Bool
    let cleanMusicData = CleanMusicData()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @Binding var showAPV: Bool
    @Binding var isLoading: Bool
    @State var songURL: String?
    @EnvironmentObject var cardProgress: CardProgress
    @EnvironmentObject var cardPrep: CardPrep

    
    
    
    @State private var disableSelect = false
    @ObservedObject var gettingRecord = GettingRecord.shared
    @EnvironmentObject var chosenSong: ChosenSong
    @EnvironmentObject var appState: AppState
    enum ActiveAlert: Identifiable {
        case songNotAvailable, noConnection
        var id: Int {
            switch self {
            case .songNotAvailable:
                return 1
            case .noConnection:
                return 2
            }
        }
    }
    @State private var activeAlert: ActiveAlert?

    var body: some View {
            AMPlayerView
            .alert(item: $activeAlert) { alertType -> Alert in
                switch alertType {
                case .songNotAvailable:
                    return Alert(title: Text("Song Not Available"), message: Text("Sorry, this song isn't available. Please select a different one."), dismissButton: .default(Text("OK")){showAPV = false})
                case .noConnection:
                    return Alert(title: Text("Network Error"), message: Text("Sorry, we weren't able to connect to the internet. Please reconnect and try again."), dismissButton: .default(Text("OK")))
                }
            }
        
        
        
        
            .onAppear{print("AM PLAYER APPEARED...."); if let songArtImageData = songArtImageData, songArtImageData.isEmpty {
                if networkMonitor.isConnected{
                    print("calling get storefront and token")
                    getAMUserTokenAndStoreFront{}}
                else{activeAlert = .noConnection}
            }
                
            }

            .navigationBarItems(leading:Button {
                if fromFinalize {musicPlayer.pause(); cardProgress.currentStep = 4; appState.currentScreen = .buildCard([.musicSearchView])}
                        print("Calling completion...")
                        musicPlayer.pause()
                        showGrid = true
                        chosenCard = nil
            } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
    }
    
    var AMPlayerView: some View {
        VStack(alignment: .center) {
            //if songArtImageData != nil {Image(uiImage: UIImage(data: songArtImageData!)!)}
            if let songArtImageData = songArtImageData, let uiImage = UIImage(data: songArtImageData) {
                        Image(uiImage: uiImage)
                    }
            if let name = songName, let urlString = songURL, let url = URL(string: urlString) {
                Link(name, destination: url)
            }
            else{
                Text(songName ?? "Loading...")
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            Text(songArtistName!)
                .multilineTextAlignment(.center)
            HStack {
                Spacer()
                HStack {
                    Button {
                        musicPlayer.setQueue(with: [songID!])
                        musicPlayer.play()
                        songProgress = 0.0
                        isPlaying = true
                    } label: {
                        ZStack {
                            Circle()
                                .accentColor(.pink)
                                .shadow(radius: 10)
                            Image(systemName: "arrow.uturn.backward" )
                                .foregroundColor(.white)
                                .font(.system(.title))
                        }
                    }
                    .frame(maxWidth: UIScreen.screenHeight/12, maxHeight: UIScreen.screenHeight/12)
                    Button {
                        isPlaying.toggle()
                        if musicPlayer.playbackState.rawValue == 1 {musicPlayer.pause()}
                        else {musicPlayer.play()}
                    } label: {
                        ZStack {
                            Circle()
                                .accentColor(.pink)
                                .shadow(radius: 10)
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
                Image("AMIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24) // height as per your text field
                    .padding([.top, .leading]), // add padding to top and leading
                alignment: .bottomTrailing //
            )

            ProgressView(value: songProgress, total: songDuration!)
                .onReceive(timer) {_ in
                    //if songProgress < songDuration! && musicPlayer.playbackState.rawValue == 1 {songProgress += 1}
                    songProgress = musicPlayer.currentPlaybackTime
                    if songProgress == songDuration {musicPlayer.pause()}
                }
            HStack{
                //if songProgress > 0.0 {
                    Text(convertToMinutes(seconds:Int(songProgress)))
                    Spacer()
                    Text(convertToMinutes(seconds: Int(songDuration!)-Int(songProgress)))
                        .padding(.trailing, 10)
                //}
            }
            if confirmButton == true {selectButton}
        }
        .onChange(of: appState.pauseMusic) {shouldPause in if shouldPause{self.musicPlayer.pause()}}
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // This should make the VStack take up all available space and align its contents to the center.
        .onAppear{songProgress = 0.0;
            if networkMonitor.isConnected {
                self.musicPlayer.setQueue(with: [songID!]);
                self.musicPlayer.play()
                print("Song ID....")
                print(songID)
                if self.musicPlayer.playbackState.rawValue == 0 && songID != "" {print("NotPlaying..."); self.disableSelect = true; activeAlert = .songNotAvailable}
                print("<<<<\(self.musicPlayer.playbackState.rawValue)")
            }
            else {activeAlert = .noConnection}
            startCheckingPlaybackState()
        }
        .onDisappear{
            print("AMPlayerView did disappear")
            self.musicPlayer.pause(); self.$musicPlayer.wrappedValue.currentPlaybackTime = 0}
        
    }
    
    @ViewBuilder var selectButton: some View {
        Button {
            musicPlayer.pause()
            songProgress = 0.0
            self.showAPV = false
            self.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.isLoading = false
                cardPrep.chosenSong = chosenSong
                cardPrep.cardType = "musicNoGift"
                cardProgress.currentStep = 5;
                appState.currentScreen = .buildCard([.finalizeCardView])
            }
        } label: {Text("Select Song For Card").foregroundColor(.blue).disabled(disableSelect)}
        //else {Text("")}
    }
    
    func convertToMinutes(seconds: Int) -> String {
        let m = seconds / 60
        let s = String(format: "%02d", seconds % 60)
        let completeTime = String("\(m):\(s)")
        return completeTime
    }
}

extension AMPlayerView {
    
    func startCheckingPlaybackState() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.musicPlayer.playbackState == .paused {self.isPlaying = false}
            else {self.isPlaying = true}
        }
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
                    if songName! == "" {
                        print("attempting convert...")
                        convertSong(offset: nil)
                        
                        
                    }
                    completion()
                }
            }
        }
    }

    func convertSong(offset: Int?) {
        var foundMatch = "isSearching" // Move this variable to the outer loop
        var triggerFoundMatchCheck = false
        //let offsetVals: [Int?] = [nil, 25, 50, 75]
        //let group = DispatchGroup()
        //outerLoop: for offsetVal in offsetVals {
        //    print("Offsetval....\(offsetVal)")
        //    group.enter()
        
        amAPI.searchForAlbum(albumAndArtist:  "\(songAlbumName!) \(spotAlbumArtist!)", storeFrontID: amAPI.storeFrontID!, offset: offset, userToken: amAPI.taskToken!, completion: {(albumResponse, error) in
                print(error?.localizedDescription as Any)
                if error != nil {
                    print("search did fail...")
                    print(songPreviewURL)
                    DispatchQueue.main.async {
                        
                        foundMatch = "searchFailed"
                        if songPreviewURL == nil || songPreviewURL == "" {CardPrep.shared.objectWillChange.send()
                            ; cardPrep.cardType = "noMusicNoGift"}
                        else {
                            print("Defer to preview")
                            deferToPreview = true
                        }
                    }
                }
            else {
                //if error != nil {foundMatch = "searchFailed"}
                let cleanSpotString =  cleanMusicData.compileMusicString(songOrAlbum: spotName!, artist: spotArtistName!, removeList: appDelegate.songFilterForMatchRegex)
                if let albumList = albumResponse?.results.albums.data {
                    let group = DispatchGroup()
                    //let group2 = DispatchGroup()
                //secondLoop:
                    for (albumIndex, album) in albumList.enumerated() {
                        //group.enter()
                        group.enter()
                        print("Album Object from AM...")
                        print("----\(album.attributes.name)----\(album.id)")
                        AppleMusicAPI().getAlbumTracks(albumId: album.id, storefrontId: amAPI.storeFrontID!, userToken: amAPI.taskToken!, completion: { (trackResponse, error) in
                            defer { group.leave() }
                            if trackResponse != nil {
                                if let trackList = trackResponse?.data {
                                    for (trackIndex, track) in trackList.enumerated() {
                                        print("Track Index....\(trackIndex) of \(trackList.count - 1)")
                                        print("Album Index....\(albumIndex) of \(albumList.count - 1)")
                                        let cleanAMString = cleanMusicData.compileMusicString(songOrAlbum: track.attributes.name, artist: track.attributes.artistName, removeList: appDelegate.songFilterForMatchRegex)
                                        if cleanMusicData.containsSameWords(cleanAMString, cleanSpotString) && foundMatch != "foundMatch" {
                                            foundMatch = "foundMatch"
                                            print("SSSSS")
                                            print(Double(track.attributes.durationInMillis) * 0.001)
                                            let artURL = URL(string:album.attributes.artwork.url.replacingOccurrences(of: "{w}", with: "80").replacingOccurrences(of: "{h}", with: "80"))
                                            let _ = getURLData(url: artURL!, completionHandler: { (artResponse, error2) in
                                                songName = track.attributes.name
                                                songArtistName = track.attributes.artistName
                                                songID = track.id
                                                songURL = track.attributes.url
                                                songArtImageData = artResponse!
                                                songDuration = Double(track.attributes.durationInMillis) * 0.001
                                                musicPlayer.setQueue(with: [songID!])
                                                musicPlayer.play()
                                            })}
                                        if trackIndex == trackList.count - 1 && albumIndex == albumList.count - 1 {
                                            print("Trigerred Found Match Check...")
                                            triggerFoundMatchCheck = true}
                                    }
                                }}
                        })}
                    group.notify(queue: .main) {
                        // This code is executed after all the requests have been completed
                        if (triggerFoundMatchCheck && foundMatch == "isSearching") {
                            print("search did fail...")
                            print(songPreviewURL == "")
                            DispatchQueue.main.async {
                                foundMatch = "searchFailed"
                                if songPreviewURL == nil || songPreviewURL == "" {CardPrep.shared.objectWillChange.send()
                                    ; cardPrep.cardType = "noMusicNoGift"}
                                else {
                                    print("Defer to preview")
                                    deferToPreview = true
                                }
                            }
                        }}
                    }}})}

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
