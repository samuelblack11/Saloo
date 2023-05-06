//
//  AMPlayerView.swift
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

struct AMPlayerView: View {
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
    @Binding var showFCV: Bool
    @State private var player: AVPlayer?
    @State private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    var amAPI = AppleMusicAPI()
    @State private var ranAMStoreFront = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var fromFinalize = false
    @State var showWriteNote = false
    @State var showGrid = false
    @State var associatedRecord: CKRecord?
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

    
    var body: some View {
            AMPlayerView
            .fullScreenCover(isPresented: $showWriteNote) {WriteNoteView()}
            .onAppear{print("AM PLAYER APPEARED...."); if songArtImageData == nil{getAMUserToken(); getAMStoreFront()}}
            //.onAppear{if songName! == nil{getAMUserToken(); getAMStoreFront()}}

            .navigationBarItems(leading:Button {
                if fromFinalize {musicPlayer.pause(); showWriteNote = true}
                        print("Calling completion...")
                        musicPlayer.pause()
                        showGrid = true
                        chosenCard = nil
            } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
    }
    
    var AMPlayerView: some View {
        VStack {
            if songArtImageData != nil {Image(uiImage: UIImage(data: songArtImageData!)!)}
            Text(songName!)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Text(songArtistName!)
                .multilineTextAlignment(.center)
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
            ProgressView(value: songProgress, total: songDuration!)
                .onReceive(timer) {_ in
                    //if songProgress < songDuration! && musicPlayer.playbackState.rawValue == 1 {songProgress += 1}
                    songProgress = musicPlayer.currentPlaybackTime
                    if songProgress == songDuration {musicPlayer.pause()}
                }
            HStack{
                Text(convertToMinutes(seconds:Int(songProgress)))
                Spacer()
                Text(convertToMinutes(seconds: Int(songDuration!)-Int(songProgress)))
                    .padding(.trailing, 10)
            }
            selectButton
        }
        .onAppear{self.musicPlayer.setQueue(with: [songID!]); self.musicPlayer.play()}
        .onDisappear{self.musicPlayer.pause()}
    }
    
    @ViewBuilder var selectButton: some View {
        if confirmButton == true {Button {
            showFCV = true
            musicPlayer.pause()
            songProgress = 0.0

            
        } label: {Text("Select Song For Card").foregroundColor(.blue)}}
        else {Text("")}
    }
    
    func convertToMinutes(seconds: Int) -> String {
        let m = seconds / 60
        let s = String(format: "%02d", seconds % 60)
        let completeTime = String("\(m):\(s)")
        return completeTime
    }
}

extension AMPlayerView {
        
    func getAMUserToken() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if amAPI.taskToken == nil {
                SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {amAPI.getUserToken(completionHandler: { (response, error) in
                    print("Checking Token")
                    print(response as Any)
                    print("^^")
                    print(error as Any)
        })}}}}}
    
    func getAMStoreFront() {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if amAPI.taskToken != nil && ranAMStoreFront == false {
                    ranAMStoreFront = true
                    SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
                        amAPI.storeFrontID = amAPI.fetchUserStorefront(userToken: amAPI.taskToken!, completionHandler: { ( response, error) in
                            amAPI.storeFrontID = response!.data[0].id
                            if songName! == "" {
                                convertSong(offset: nil)
                            }
                        })}}}
            }
    }
    

    func cleanAMSongForSPOTComparison(amSongName: String, amSongArtist: String) -> String {
        var AMString = String()
        var cleanSongName = removeSubstrings(from: amSongName, removeList: appDelegate.songFilterForMatch)
        var cleanSongArtistName = amSongArtist
                                            .replacingOccurrences(of: ",", with: "")
                                            .replacingOccurrences(of: "&", with: "")
        var artistsInSongName = String()
        var featStrings = ["(feat.", "[feat."]
        for featString in featStrings {
            if amSongName.contains(featString) {
                let songComponents = amSongName.components(separatedBy: featString)
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
        var cleanSongName = removeSubstrings(from: spotSongName, removeList: appDelegate.songFilterForMatch)

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
        print("SPOTString....")
        print(SPOTString)
        return SPOTString
    }
    
    func convertSong(offset: Int?) {
        var foundMatch = "isSearching" // Move this variable to the outer loop
        var triggerFoundMatchCheck = false
        //let offsetVals: [Int?] = [nil, 25, 50, 75]
        //let group = DispatchGroup()
        //outerLoop: for offsetVal in offsetVals {
        //    print("Offsetval....\(offsetVal)")
        //    group.enter()
        amAPI.searchForAlbum(albumAndArtist: removeSubstrings(from: "\(songAlbumName!) \(spotAlbumArtist!)", removeList: appDelegate.songFilterForMatch), storeFrontID: amAPI.storeFrontID!, offset: offset, userToken: amAPI.taskToken!, completion: {(albumResponse, error) in
                print("Tried to Convert...\(removeSubstrings(from: songAlbumName!, removeList: appDelegate.songFilterForMatch))")
                print(error?.localizedDescription as Any)
                //if error != nil {foundMatch = "searchFailed"}
                let cleanSpotString = cleanSPOTSongForAMComparison(spotSongName: spotName!, spotSongArtist: spotArtistName!)
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
                                        if containsSameWords(cleanAMSongForSPOTComparison(amSongName: track.attributes.name, amSongArtist: track.attributes.artistName), cleanSpotString) {
                                            foundMatch = "foundMatch"
                                            print("SSSSS")
                                            print(Double(track.attributes.durationInMillis) * 0.001)
                                            let artURL = URL(string:album.attributes.artwork.url.replacingOccurrences(of: "{w}", with: "80").replacingOccurrences(of: "{h}", with: "80"))
                                            let _ = getURLData(url: artURL!, completionHandler: { (artResponse, error2) in
                                                songName = track.attributes.name
                                                songArtistName = track.attributes.artistName
                                                songID = track.id
                                                songArtImageData = artResponse!
                                                songDuration = Double(track.attributes.durationInMillis) * 0.001
                                                musicPlayer.setQueue(with: [songID!])
                                                musicPlayer.play()
                                                DispatchQueue.main.async {
                                                    updateRecordWithNewAMData(songName: songName!, songArtistName: songArtistName!, songID: songID!, songArtImageData: artResponse!, songDuration: String(songDuration!))
                                                //group.leave()
                                                }})}
                                        
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
                            foundMatch = "searchFailed"
                            if songPreviewURL != nil {
                                print("Defer to preview")
                                deferToPreview = true
                                DispatchQueue.main.async {
                                    updateRecordWithNewAMData(songName: "LookupFailed", songArtistName: "LookupFailed", songID: "LookupFailed", songArtImageData: Data(), songDuration: String(0))
                        }}}
                    }}})}


    
    func updateRecordWithNewAMData(songName: String, songArtistName: String, songID: String, songArtImageData: Data, songDuration: String) {
        let controller = PersistenceController.shared
        let taskContext = controller.persistentContainer.newTaskContext()
        let ckContainer = PersistenceController.shared.cloudKitContainer
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        print("About to run AM Data update on the CKRecord....")
        controller.updateRecordWithAMData(for: coreCard!, in: taskContext, with: ckContainer.privateCloudDatabase, songName: songName, songArtistName: songArtistName,songID: songID, songImageData: songArtImageData, songDuration: songDuration, completion: { (error) in
            print("Updated Record...")
            print(error as Any)
        } )
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
    
    func loadCoreCards() -> [CoreCard] {
        let request = CoreCard.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        var cardsFromCore: [CoreCard] = []
        do {
            cardsFromCore = try PersistenceController.shared.persistentContainer.viewContext.fetch(request)
            print("AM PLAYER Got \(cardsFromCore.count) Cards From Core")
        }
        catch {print("Fetch failed")}
        return cardsFromCore
    }
    
    func convertMultipleSpacesToSingleSpace(_ input: String) -> String {
        let components = input.components(separatedBy: .whitespacesAndNewlines)
        let filtered = components.filter { !$0.isEmpty }
        return filtered.joined(separator: " ")
    }
    
    func removeSubstrings(from string: String, removeList: [String]) -> String {
        var result = string
        for substring in removeList {
            result = result.lowercased().replacingOccurrences(of: substring, with: "")
            result = result.capitalized
        }
        return result
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
    func removeAccents(from input: String) -> String {
        let accentMap: [Character: Character] = [
            "à": "a",
            "á": "a",
            "â": "a",
            "ã": "a",
            "ä": "a",
            "å": "a",
            //"æ": "ae",
            "ç": "c",
            "è": "e",
            "é": "e",
            "ê": "e",
            "ë": "e",
            "ì": "i",
            "í": "i",
            "î": "i",
            "ï": "i",
            "ð": "d",
            "ñ": "n",
            "ò": "o",
            "ó": "o",
            "ô": "o",
            "õ": "o",
            "ö": "o",
            "ø": "o",
            "ù": "u",
            "ú": "u",
            "û": "u",
            "ü": "u",
            "ý": "y",
            //"þ": "th",
            "ÿ": "y"
        ]
    
        var output = ""
        for character in input {
            if let unaccented = accentMap[character] {
                output.append(unaccented)
            } else {
                output.append(character)
            }
        }

        return output
    }
}
