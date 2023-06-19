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
import Security

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


class ScreenManager: ObservableObject {
    static let shared = ScreenManager()
    // The range of IDs to cycle through
    let ids = Array(1...5)
    // The current index in the ID array
    @Published var currentIndex = 0

    var currentId: Int { ids[currentIndex] }

    func advance() {
        print("Pre-Advance Index \(currentIndex)")
        currentIndex = (currentIndex + 1) % ids.count
        print("Post-Advance Index \(currentIndex)")
    }
}






class CardsForDisplay: ObservableObject {
    static let shared = CardsForDisplay()
    @Published var inboxCards: [CoreCard] = []
    @Published var outboxCards: [CoreCard] = []
    @Published var draftboxCards: [CoreCard] = []
    
    let userID = UserDefaults.standard.object(forKey: "SalooUserID") as? String
    
    func loadCoreCards() {
        print("LoadCoreCards called...")
        let request = CoreCard.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            let cardsFromCore = try PersistenceController.shared.persistentContainer.viewContext.fetch(request)
            
            // Split the cards into separate lists
            inboxCards = cardsFromCore.filter { !$0.salooUserID!.contains(self.userID!) }
            outboxCards = cardsFromCore.filter { card in
                let (isCardShared, _) = shareStatus(card: card)
                return self.userID!.contains(card.salooUserID!) && isCardShared
            }
            draftboxCards = cardsFromCore.filter { card in
                let (isCardShared, _) = shareStatus(card: card)
                return self.userID!.contains(card.salooUserID!) && !isCardShared
            }
        }
        catch {
            print("Fetch failed")
        }
    }
    
    func shareStatus(card: CoreCard) -> (Bool, Bool) {
        var isCardShared: Bool?
        var hasAnyShare: Bool?
        isCardShared = (PersistenceController.shared.existingShare(coreCard: card) != nil)
        hasAnyShare = PersistenceController.shared.shareTitles().isEmpty ? false : true
        
        return (isCardShared!, hasAnyShare!)
    }
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

class UserSession: ObservableObject {
    @Published var isSignedIn: Bool = UserDefaults.standard.string(forKey: "SalooUserID") != nil
    
    func updateLoginStatus() {
        isSignedIn = UserDefaults.standard.string(forKey: "SalooUserID") != nil
    }
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
    var cardType = String()
}


class UCVImageObjectModel: ObservableObject {
    @Published var imageObjects: [CoverImageObject] = []
    
    func getPhotosFromCollection(collectionID: String, page_num: Int) {
        PhotoAPI.getPhotosFromCollection(collectionID: collectionID, page_num: page_num, completionHandler: { (response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    for picture in response! {
                        if picture.urls.small != nil && picture.user.username != nil && picture.user.name != nil && picture.links.download_location != nil {
                            let thisPicture = picture.urls.small
                            let imageURL = URL(string: thisPicture!)
                            let newObj = CoverImageObject.init(coverImage: nil, smallImageURL: imageURL!, coverImagePhotographer: picture.user.name!, coverImageUserName: picture.user.username!, downloadLocation: picture.links.download_location!, index: self.imageObjects.count)
                            self.imageObjects.append(newObj)
                    }}
                }
            }
            if response != nil {print("No Response!")}
            else {debugPrint(error?.localizedDescription ?? "Error Getting Photos from Collection")}
        })
    }
}



class APIManager: ObservableObject {
    static let shared = APIManager()
    let baseURL = "https://getSalooKeys.azurewebsites.net/getkey"
    @Published var unsplashAPIKey = String()
    var unsplashSecretKey = String()
    var spotSecretKey = String()
    var spotClientIdentifier = String()
    var appleMusicDevToken = String()
    var keys: [String: String] = [:]
    //guard let url = URL(string: "https://saloouserstatus.azurewebsites.net/is_banned?user_id=\(userId)")
    //@Published var spotifyManager: SpotifyManager?



    init() {
        DispatchQueue.global(qos: .background).async {
            self.getSecret(keyName: "unsplashAPIKey") { keyval in
                print("UnsplashAPIKey is \(String(describing: keyval))")
                DispatchQueue.main.async {
                    self.unsplashAPIKey = keyval ?? ""
                    CollectionManager.shared.createOccassionsFromUserCollections()
                }
            }

            self.getSecret(keyName: "appleMusicDevToken") { keyval in
                print("appleMusicDevToken is \(String(describing: keyval))")
                DispatchQueue.main.async {self.appleMusicDevToken = keyval ?? ""}
            }
        }
    }

    
    func initializeSpotifyManager(completion: @escaping () -> Void) {
        // Here, you're getting the keys for Spotify API
        DispatchQueue.global(qos: .background).async {
            self.getSecret(keyName: "spotClientIdentifier") { keyval in
                print("spotClientIdentifier is \(String(describing: keyval))")
                DispatchQueue.main.async {
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
        }
    }

    func getSecret(keyName: String, completion: @escaping (String?) -> Void) {
        //let url = baseURL.appendingPathComponent("getkey")
        if let storedKey = loadFromKeychain(key: keyName) {
            completion(storedKey)
            return
        }
        
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
                            // Save the key to Keychain
                            self.saveToKeychain(key: keyName, value: value)
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
    
    
    
    func saveToKeychain(key: String, value: String) {
        let keyData = key.data(using: .utf8)!
        let valueData = value.data(using: .utf8)!
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: keyData,
                                    kSecValueData as String: valueData]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Failed to save data to Keychain")
            return
        }
    }

    func loadFromKeychain(key: String) -> String? {
        let keyData = key.data(using: .utf8)!
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: keyData,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            print("Failed to load data from Keychain")
            return nil
        }
        
        let valueData = item as! Data
        print("Got Key \(String(data: valueData, encoding: .utf8)) for \(key)")
        return String(data: valueData, encoding: .utf8)
    }
}

class CollectionManager: ObservableObject {
    static let shared = CollectionManager()
    @Published var collections: [CollectionPair2] = []
    private var timer: Timer?
    
    let titleToType = [
        "Birthday 🎈": CollectionType.yearRound,
        "Postcard ✈️": CollectionType.yearRound,
        "Anniversary 💒": CollectionType.yearRound,
        "Graduation 🎓": CollectionType.yearRound,
        "Christmas 🎄": CollectionType.winter,
        "Hanukkah 🕎": CollectionType.winter,
        "New Years Eve 🎆": CollectionType.winter,
        "Mother's Day 🌸": CollectionType.spring,
        "4th of July 🎇": CollectionType.summer,
        "Father's Day 🍻": CollectionType.summer,
        "Thanksgiving 🍁": CollectionType.fall,
        "Rosh Hashanah 🔯": CollectionType.fall,
    ]

    
    func createOccassionsFromUserCollections() {
        print("Calling....")
        PhotoAPI.getUserCollections(username: "samuelblack11", completionHandler: { (response, error) in
            if response != nil {
                var allCollections = [CollectionPair2]()

                for collection in response! {
                    if self.titleToType.contains(where: { $0.key == collection.title }) {
                        // Look up the type, defaulting to yearRound if not found
                        let type = self.titleToType[collection.title] ?? .yearRound
                        let collectionPair = CollectionPair2(title: collection.title, id: collection.id, type: type.rawValue)
                        allCollections.append(collectionPair)
                    }
                }

                DispatchQueue.main.async {
                    self.collections = allCollections
                }
            } else if error != nil {
                print("No Response!")
                debugPrint(error?.localizedDescription)
            }
        })
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
