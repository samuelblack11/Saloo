//
//  CustomDataTypes.swift
//  GreetMe-2
//
//  Created by Sam Black on 12/24/22.
//

import Foundation
import UIKit
import SwiftUI
import CloudKit
import Network


struct ChosenCollection {@State var occassion: String!; @State var collectionID: String!}
class ChosenCoreCard: ObservableObject {@Published var chosenCard = CoreCard()}
class Occassion: ObservableObject {@Published var occassion = String(); @Published var collectionID = String()}
public class ShowDetailView: ObservableObject {@Published public var showDetailView: Bool = false}
class TaskToken: ObservableObject {@Published var taskToken = String()}


class NetworkMonitor: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}


struct SongForList: Hashable {
     var id: String
     var name: String
     var artistName: String
     var albumName: String
     var artImageData: Data
     var durationInMillis: Int
     var isPlaying: Bool
     var previewURL: String
     var disc_number: Int?
     var url: String
}

struct SelectedSong {
    @State var id: String?
    @State var name: String?
    @State var artistName: String?
    @State var artImageData: Data?
    @State var isPlaying: Bool?
    @State var durationInMillis: Int
}

class GiftCard: ObservableObject {
    @Published var id = ""
    @Published var status = String()
    @Published var cardValue = Int()
    @Published var deliveryMethod = String()
    @Published var recipientEmail = String()
    @Published var recipientName = String()
}

struct UserResponseParent: Codable {
    let usersList: [UserResponse]
}

struct UserResponse: Codable {
    let users: [User]
}

struct User: Codable {
    let partitionKey: String
    let rowKey: String
    let isBanned: Bool
}



class CoreCardWrapper: ObservableObject {
    @Published var enableShare = false
    @Published var coreCard = CoreCard()
}



class ChosenSong: ObservableObject {
    @Published var id = String()
    @Published var name = String()
    @Published var artistName = String()
    @Published var artwork = Data()
    @Published var isPlaying = Bool()
    @Published var durationInSeconds = Double()
    @Published var songPreviewURL = String()
    @Published var songAlbumName = String()
    @Published var spotID = String()
    @Published var spotName = String()
    @Published var spotArtistName = String()
    @Published var spotImageData = Data()
    @Published var spotSongDuration = Double()
    @Published var spotPreviewURL = String()
    @Published var songAddedUsing = String()
    @Published var appleAlbumArtist = String()
    @Published var spotAlbumArtist = String()
    @Published var discNumber = Int()
    @Published var appleSongURL = String()
    @Published var spotSongURL = String()

}

class ChosenCoverImageObject: ObservableObject {
    @Published var id = UUID()
    @Published var coverImage = Data()
    @Published var smallImageURLString = String()
    @Published var coverImagePhotographer = String()
    @Published var coverImageUserName = String()
    @Published var downloadLocation = String()
    @Published var index = Int()
    @Published var frontCoverIsPersonalPhoto = Int()
    @Published var pageCount = 1
    //func hash(into hasher: inout Hasher) {
    //    hasher.combine(downloadLocation)
    //}
}

class NoteField: ObservableObject  {
    @Published var noteText = MaximumText(limit: 225, value:  "Write Your Note Here")
    @Published var recipient = MaximumText(limit: 20, value: "To:")
    @Published var sender = MaximumText(limit: 20, value: "From:")
    @Published var cardName = MaximumText(limit: 20, value: "Name Your Card")
    @Published var font = "Papyrus"
    @Published var willHandWrite = Bool()
    @Published var eCardText = String()
    @Published var printCardText = String()
}

class MaximumText: ObservableObject {
    // variable for character limit
    private let limit: Int
    init(limit: Int, value: String) {
        self.limit = limit
        self.value = value
    }
    
    // value that text field displays
    @Published var value: String {
        didSet {
            if value.count > self.limit {
                value = String(value.prefix(self.limit))
                self.hasReachedLimit = true
            } else {
                self.hasReachedLimit = false
            }
        }
    }
    
    @Published var hasReachedLimit = false
}

struct CoverImageObject: Identifiable, Hashable {
    let id = UUID()
    let coverImage: Data?
    let smallImageURL: URL
    let coverImagePhotographer: String
    let coverImageUserName: String
    let downloadLocation: String
    let index: Int
    func hash(into hasher: inout Hasher) {
        hasher.combine(downloadLocation)
    }
}

class Annotation: ObservableObject {
    @Published var text1 = String()
    @Published var text2 = String()
    @Published var text2URL = URL(string: "https://google.com")!
    @Published var text3 = String()
    @Published var text4 = String()
}

//class CollageImage: ObservableObject {@Published var collageImage = UIImage()}

class CollageImage: ObservableObject {
    @Published var chosenStyle = Int()
    @Published var collageImage = Data()
    @Published var image1 = Data()
    @Published var image2 = Data()
    @Published var image3 = Data()
    @Published var image4 = Data()

}


class AddMusic: ObservableObject {@Published var addMusic: Bool = false}




public class ChosenImages: ObservableObject {
    @Published var imagePlaceHolder: Image?
    @Published var chosenImageA: UIImage?
    @Published var chosenImageB: UIImage?
    @Published var chosenImageC: UIImage?
    @Published var chosenImageD: UIImage?
}

class InOut: ObservableObject {
    enum SendReceive {
        case inbox
        case outbox
        case draftbox
    }
}

class MusicSubscription: ObservableObject {
    @Published var timeToAddMusic = false
    @Published var type: MusicSubscriptionOptions = .Neither
}

enum MusicSubscriptionOptions {
    case Apple
    case Spotify
    case Neither
}
class UnmanagedPlaceHolder: NSObject {}

class ChosenCollageStyle: ObservableObject {@Published var chosenStyle: Int?}
class SpotifyAuth: ObservableObject {
    @Published var authForRedirect = String()
    @Published var auth_code = String()
    //@Published var returnedRedirectURI = String()
    @Published var access_Token = String()
    @Published var refresh_Token = String()
    @Published var deviceID = String()
    @Published var playingSong = Bool()
    @Published var userID = String()
    @Published var salooPlaylistID = String()
    @Published var songID = String()
    @Published var snapShotID = String()
}

class AlertVars: ObservableObject {
    static let shared = AlertVars()
    @Published var activateAlert: Bool = false
    @Published var alertType: ActiveAlert = .signInFailure
    private init() {}
    
    var activateAlertBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.activateAlert },
            set: { self.activateAlert = $0 }
        )
    }
    
    
}


class CollageBlocksAndViews {

    func blockForStyle() -> some View {return GeometryReader {geometry in HStack(spacing: 0) {Rectangle().fill(Color.gray).border(Color.black)}}}
    func onePhotoView(block: some View) -> some View {return block}
    func twoPhotoWide(block: some View) -> some View {return VStack(spacing:0){block; block}}
    func twoPhotoLong(block: some View) -> some View {return HStack(spacing:0){block; block}}
    func twoShortOneLong(block: some View) -> some View {return HStack(spacing:0){VStack(spacing:0){block; block}; block}}
    func twoNarrowOneWide(block: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){block; block}; block}}
    func fourPhoto(block: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){block; block}; HStack(spacing:0){block; block}}}
    
}

enum ActiveSheet: Identifiable, Equatable {
    #if os(iOS)
    case photoPicker // Unavailable in watchOS.
    #elseif os(watchOS)
    case photoContextMenu(CoreCard) // .contextMenu is deprecated in watchOS, so use action list instead.
    #endif
    case cloudSharingSheet(CKShare)
    case managingSharesView
    case sharePicker(CoreCard)
    case taggingView(CoreCard)
    case ratingView(CoreCard)
    case participantView(CKShare)
    /**
     Use the enumeration member name string as the identifier for Identifiable.
     In the case where an enumeration has an associated value, use the label, which is equal to the member name string.
     */
    var id: String {
        let mirror = Mirror(reflecting: self)
        if let label = mirror.children.first?.label {
            return label
        } else {
            return "\(self)"
        }
    }
    
    
    

}


enum eCardType {
    case musicAndGift
    case musicNoGift
    case giftNoMusic
    case noMusicNoGift
}


class CardPrep: ObservableObject {
    static let shared = CardPrep()
    var chosenSong =  ChosenSong()
    func determineCardType() -> String {
        var cardType2 = String()
        if chosenSong.id != "" {cardType2 = "musicNoGift"}
        else{cardType2 = "noMusicNoGift"}
        
        return cardType2
        
    }
}






class APIManager: ObservableObject {
    static let shared = APIManager()
    let baseURL = "https://getSalooKeys.azurewebsites.net/getkey"
    var unsplashAPIKey = String()
    var unsplashSecretKey = String()
    var spotSecretKey = String()
    var spotClientIdentifier = String()
    var appleMusicDevToken = String()
    var keys: [String: String] = [:]
    //guard let url = URL(string: "https://saloouserstatus.azurewebsites.net/is_banned?user_id=\(userId)")
    //@Published var spotifyManager: SpotifyManager?



    init() {
        getSecret(keyName: "unsplashAPIKey"){keyval in print("UnsplashAPIKey is \(String(describing: keyval))")
           self.unsplashAPIKey = keyval!
        }

        getSecret(keyName: "appleMusicDevToken"){keyval in print("appleMusicDevToken is \(String(describing: keyval))")
           self.appleMusicDevToken = keyval!
        }
    }
    
    func initializeSpotifyManager(completion: @escaping () -> Void) {
        // Here, you're getting the keys for Spotify API
        getSecret(keyName: "spotClientIdentifier") { keyval in
            print("spotClientIdentifier is \(String(describing: keyval))")
            self.spotClientIdentifier = keyval!
            self.getSecret(keyName: "spotSecretKey"){keyval in print("spotSecretKey is \(String(describing: keyval))")
                self.spotSecretKey = keyval!
                // After setting the key, initialize SpotifyManager
                SpotifyManager.shared.initializeConfiguration()
                //self.spotifyManager = SpotifyManager.shared
                // Call the completion handler
                completion()
            }
        }
    }

    func getSecret(keyName: String, completion: @escaping (String?) -> Void) {
        //let url = baseURL.appendingPathComponent("getkey")
        
        let fullURL = baseURL + "?keyName=\(keyName)"
        print(fullURL)
        guard let url = URL(string: fullURL) else {fatalError("Invalid URL")}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            //print(response)
            //print(String(data: data!, encoding: .utf8))
            if let error = error {
                print("Error: \(error)")
                completion(nil)
            } else if let data = data {
                let jsonData = String(data: data, encoding: .utf8)
                if let jsonData = jsonData {
                    let data = Data(jsonData.utf8)
                    do {
                        // Make sure that the Decoder Setup matches your JSON Structure
                        let json = try JSONDecoder().decode([String: String].self, from: data)
                        if let value = json["value"] {
                            completion(value)
                        }
                    } catch {
                        print("error:\(error)")
                    }
                }
            }
        }

        task.resume()
    }
    
    
    func getSecrets(keyNames: [String], completion: @escaping ([String: String]) -> Void) {
         let keyNamesString = keyNames.joined(separator: ",")
         let fullURL = baseURL + "?keyNames=\(keyNamesString)"
         print(fullURL)
         guard let url = URL(string: fullURL) else {fatalError("Invalid URL")}
         let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
             print(response)
             print(String(data: data!, encoding: .utf8))
             if let error = error {
                 print("Error: \(error)")
                 completion([:])
             } else if let data = data {
                 do {
                     let decodedData = try JSONDecoder().decode([String: String].self, from: data)
                     completion(decodedData)
                 } catch {
                     print("Error decoding data: \(error)")
                     completion([:])
                 }
             }
         }

         task.resume()
     }
    
    
}


class SpotifyManager: ObservableObject {
    static let shared = SpotifyManager()
    var config: SPTConfiguration?
    var auth_code = String()
    var refresh_token = String()
    var access_token = String()
    var authForRedirect = String()
    var songID = String()
    var appRemote: SPTAppRemote? = nil
    let spotPlayerDelegate = SpotPlayerViewDelegate()
    
    init() {
        enum UserDefaultsError: Error {case noMusicSubType}
        do {
            guard let musicSubType = UserDefaults.standard.object(forKey: "MusicSubType") as? String, musicSubType == "Spotify" else {
                throw UserDefaultsError.noMusicSubType
            }
        } catch {print("Caught error: \(error)")}
    }
    
    func initializeConfiguration() {
        let spotClientIdentifier = APIManager.shared.spotClientIdentifier
        if spotClientIdentifier.isEmpty {
            print("Error: Spotify client identifier is not available")
            return
        }
        config = SPTConfiguration(clientID: spotClientIdentifier, redirectURL: URL(string: "saloo://")!)
        instantiateAppRemote()
    }

    
    func instantiateAppRemote() {
        self.appRemote = SPTAppRemote(configuration: self.config!, logLevel: .debug)
        if (UserDefaults.standard.object(forKey: "SpotifyAccessToken") as? String) != nil {
            self.appRemote?.connectionParameters.accessToken = (UserDefaults.standard.object(forKey: "SpotifyAccessToken") as? String)!
            self.appRemote?.delegate = self.spotPlayerDelegate
            print("instantiated app remote...")
        }
    }
    
    func connect() {appRemote?.connect()}
    func disconnect() {appRemote?.disconnect()}
    var defaultCallback: SPTAppRemoteCallback? {
        get {
            return {[self] _, error in
                print("defaultCallBack Running...")
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

class SpotPlayerViewDelegate: NSObject, SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {print("Connected appRemote")}

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {print("Disconnected appRemote")}

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Failed to connect appRemote")
        if let error = error {print("Error: \(error)")}
    }
}
