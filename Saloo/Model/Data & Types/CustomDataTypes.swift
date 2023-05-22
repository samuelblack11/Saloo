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


class CoreCardWrapper: ObservableObject {
    @Published var enableShare = false
    @Published var coreCard = CoreCard()
}

class GettingRecord: ObservableObject {
    static let shared = GettingRecord()
    @Published var isLoadingAlert: Bool = false
    @Published var showLoadingRecordAlert: Bool = false
    @Published var didDismissRecordAlert: Bool = false
    @Published var isShowingActivityIndicator: Bool = false
    @Published var willTryAgainLater: Bool = false

    private init() {} // Ensures no other instances can be created
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
    @Published var noteText = String()
    @Published var recipient =  String()
    @Published var sender =  String()
    @Published var cardName = String()
    @Published var font = String()
    @Published var willHandWrite = Bool()
    @Published var eCardText = String()
    @Published var printCardText = String()
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


class MaximumText: ObservableObject {
    // variable for character limit
    private let limit: Int
    init(limit: Int, value: String) {self.limit = limit; self.value = value}
    // value that text field displays
    @Published var value: String {
        didSet {
            if value.count > self.limit {
                value = String(value.prefix(self.limit))
                self.hasReachedLimit = true
            } else {self.hasReachedLimit = false}
        }
    }
    @Published var hasReachedLimit = false
}

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







