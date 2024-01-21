import Foundation
import SwiftUI
import CoreData
import CloudKit
import AVFoundation
import AVFAudio
struct eCardView: View {
    
    @State var eCardText: String
    @State var font: String
    @State var collageImage: Data?
    @State var text1: String
    @State var text2: String
    @State var text2URL: URL
    @State var text3: String
    @State var text4: String
    @State var songID: String?
    @State var spotID: String?
    @State var spotName: String?
    @State var spotArtistName: String?
    @State var songName: String?
    @State var songArtistName: String?
    @State var songAlbumName: String?
    @State var appleAlbumArtist: String?
    @State var spotAlbumArtist: String?
    @State var songArtImageData: Data?
    @State var songDuration: Double?
    @State var songPreviewURL: String?
    @State var inclMusic: Bool
    @State var spotImageData: Data?
    @State var spotSongDuration: Double?
    @State var spotPreviewURL: String?
    let defaults = UserDefaults.standard
    @EnvironmentObject var appDelegate: AppDelegate
    @State var songAddedUsing: String?
    @EnvironmentObject var imageLoader: ImageLoader
    @EnvironmentObject var appState: AppState
    @State var selectedPreviewURL: String?
    @State var cardType: String
    @State var coreCard: CoreCard?
    @State var accessedViaGrid = true
    @State var fromFinalize = false
    @Binding var chosenCard: CoreCard?
    @State var deferToPreview = false
    @State private var showAPV = true
    @State private var showSPV = true
    @State private var isLoading = false
    @State private var showLoginView = false
    @State private var disableTextField = false
    @ObservedObject var gettingRecord = GettingRecord.shared
    @EnvironmentObject var spotifyManager: SpotifyManager
    @ObservedObject var alertVars = AlertVars.shared
    @State var appleSongURL: String?
    @State var spotSongURL: String?
    @State var unsplashImageURL: String?
    @State var coverSizeDetails: String
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var cardPrep: CardPrep

    @State private var hasShownLaunchView: Bool = true
    @State var coverImageIfPersonal: Data?

    let screenPadding: CGFloat = 5
    var body: some View {
        ZStack {
            if cardPrep.cardType == "musicNoGift" {MusicNoGiftView.modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))}
            else{
                if fromFinalize == false {
                    NoMusicNoGiftView
                        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
                        .navigationBarItems(leading:Button {
                            print("isSignedIn?")
                            print(userSession.isSignedIn)
                            if userSession.isSignedIn == false {showLoginView = true}
                            else{chosenCard = nil}
                        } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
                }
                else {NoMusicNoGiftView.modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))}
            }
            LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
        }
        .id(cardType)
        .onAppear {
            if CloudRecord.shared.theRecord != nil {
                CloudRecord.shared.theRecord!
            }
            DispatchQueue.main.async {
                let noPreview = (spotPreviewURL ?? "").isEmpty && (songPreviewURL ?? "").isEmpty
                if appDelegate.musicSub.type == .Neither && noPreview {
                    cardPrep.cardType = "noMusicNoGift"
                    cardType = "noMusicNoGift"
                }
            }
        }
        .fullScreenCover(isPresented: $showLoginView) {LaunchView(isFirstLaunch: true, isPresentedFromECardView: $showLoginView, cardFromShare: $chosenCard)}
    }
    
    
    
    var MusicNoGiftView: some View {
        return VStack {
            if getRatio(from: coverSizeDetails) < 1.3 {
                HStack {
                    VStack {CoverViewTall(); Spacer(); CollageView()}
                    VStack {
                        VStack{NoteViewSquare()}.frame(height: UIScreen.main.bounds.height / 2.3)
                        Spacer()
                        MusicView
                    }
                }
            }
            else {
                VStack {
                    VStack {
                        CoverViewWide1()
                        NoteView()
                    }
                    .frame(maxHeight: UIScreen.screenHeight/2.1)
                    HStack {CollageView(); MusicView}
                }
            }
        }.padding(.horizontal, screenPadding)
    }
    
    
    var NoMusicNoGiftView: some View {
        return GeometryReader { geometry in
            VStack(alignment: .center) {
                if getRatio(from: coverSizeDetails) < 1.3 {
                    let height = geometry.size.height / 2.2
                    HStack{CoverViewTall();CollageView()}.frame(height: height)
                    NoteViewSquare()
                }
                else {
                    VStack(alignment: .center) {
                        CoverViewWide2()
                        Spacer()
                        HStack{CollageView();NoteViewSquare()}
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }.padding(.horizontal, screenPadding)
    }
    
    func CoverView() -> some View {
        VStack {
            primaryPhotoView(aspectRatio: .fit,
                      maxWidth: .infinity,
                      maxHeight: .infinity)
        }
    }

    func CoverViewWide1() -> some View {
        GeometryReader { geometry in
            VStack {
                primaryPhotoView(aspectRatio: .fill,
                          maxWidth: geometry.size.width,
                          maxHeight: geometry.size.height)
            }
        }
        .frame(width: UIScreen.main.bounds.width/1.05, height: UIScreen.main.bounds.height / 4.1)
        .clipped()
    }


    func primaryPhotoView(aspectRatio: ContentMode, maxWidth: CGFloat, maxHeight: CGFloat) -> some View {
        Group {
            if unsplashImageURL != "https://salooapp.com" {
                Button(action: {
                    if let url = URL(string: "\(text2URL.absoluteString)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    AsyncImage(url: URL(string: unsplashImageURL!)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: aspectRatio)
                            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                    }
                }
            } else if let coverUIImage = UIImage(data: coverImageIfPersonal!) {
                Image(uiImage: coverUIImage)
                    .resizable()
                    .aspectRatio(contentMode: aspectRatio)
                    .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    .clipped()
            }
        }
    }

    func CoverViewWide2() -> some View {
        GeometryReader { geometry in
            VStack {
                primaryPhotoView(aspectRatio: .fill,
                          maxWidth: geometry.size.width,
                          maxHeight: geometry.size.height)
            }
        }
        .frame(width: UIScreen.main.bounds.width/1.05, height: UIScreen.main.bounds.height / 3.2)
        .clipped()
    }

    func CoverViewTall() -> some View {
        VStack {
            primaryPhotoView(aspectRatio: .fit,
                      maxWidth: UIScreen.main.bounds.height / 2.2,
                      maxHeight: UIScreen.main.bounds.height / 2.3)
        }
    }

    func NoteView() -> some View {
        return
        Text(eCardText)
            .font(Font.custom(font, size: 500)).minimumScaleFactor(0.01)
            .frame(width: UIScreen.screenWidth/2.2, height: UIScreen.screenHeight/4.9)
    }
    
    func NoteViewSquare() -> some View {
        return
        Text(eCardText)
            .font(Font.custom(font, size: 500)).minimumScaleFactor(0.01)
            .frame(maxWidth: UIScreen.main.bounds.height / 2.2, maxHeight: UIScreen.main.bounds.height / 2.3)
    }
    
    func CollageView() -> some View {
        VStack(spacing: 5) {
            if let imageData = collageImage, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .interpolation(.high)
                    .resizable()
                    .scaledToFit()
            }
            else {Text("No image available")}
        }
        .frame(maxWidth: UIScreen.main.bounds.height / 2.2, maxHeight: UIScreen.main.bounds.height / 2.3, alignment: .center)
    }

    var MusicView: some View {
        VStack {
            let isDeferToPreview = deferToPreview
            let isSpotLookupFailed = spotName == "LookupFailed"
            let isSongLookupFailed = songName == "LookupFailed"
            let hasPreview = !(spotPreviewURL ?? "").isEmpty || !(songPreviewURL ?? "").isEmpty
            let isSubTypeNeitherWithPreview = appDelegate.musicSub.type == .Neither && hasPreview
            if isDeferToPreview || isSpotLookupFailed || isSongLookupFailed || isSubTypeNeitherWithPreview {
                if songAddedUsing! == "Spotify"  {
                    SongPreviewPlayer(songID: spotID, songName: spotName, songArtistName: spotArtistName, songArtImageData: spotImageData, songDuration: spotSongDuration, songPreviewURL: spotPreviewURL, songURL: spotSongURL,confirmButton: false, songAddedUsing: songAddedUsing!, chosenCard: $chosenCard)
                        .frame(maxHeight: UIScreen.main.bounds.height / 2.3, alignment: .bottom)
                }
                else if songAddedUsing! == "Apple"  {
                    SongPreviewPlayer(songID: songID, songName: songName, songArtistName: songArtistName, songArtImageData: songArtImageData, songDuration: songDuration, songPreviewURL: songPreviewURL,songURL: appleSongURL, confirmButton: false, songAddedUsing: songAddedUsing!, chosenCard: $chosenCard)
                        .frame(maxHeight: UIScreen.main.bounds.height / 2.3, alignment: .bottom)
                 }
            }
             
            else if (appDelegate.musicSub.type == .Apple)  { // && (songName != "LookupFailed")
                AMPlayerView(songID: songID, songName: songName, songArtistName: songArtistName, spotName: spotName, spotArtistName: spotArtistName, songAlbumName: songAlbumName, songArtImageData: songArtImageData, songDuration: songDuration, songPreviewURL: spotPreviewURL, confirmButton: false, fromFinalize: fromFinalize, coreCard: coreCard, appleAlbumArtist: appleAlbumArtist, spotAlbumArtist: spotAlbumArtist, chosenCard: $chosenCard, deferToPreview: $deferToPreview, showAPV: $showAPV, isLoading: $isLoading,songURL: appleSongURL)
                        .frame(maxHeight: UIScreen.main.bounds.height / 2.3, alignment: .bottom)
                }
            else if (appDelegate.musicSub.type == .Spotify) { // && (spotName != "LookupFailed")
                SpotPlayerView(songID: spotID, songName: songName, songArtistName: songArtistName, spotName: spotName, spotArtistName: spotArtistName, songAlbumName: songAlbumName, songArtImageData: spotImageData, songDuration: spotSongDuration, songPreviewURL: songPreviewURL, appleAlbumArtist: appleAlbumArtist, spotAlbumArtist: spotAlbumArtist, confirmButton: false, songURL: spotSongURL, accessedViaGrid: accessedViaGrid, coreCard: coreCard, chosenCard: $chosenCard, deferToPreview: $deferToPreview, showSPV: $showSPV, isLoading: $isLoading, fromFinalize: fromFinalize)
                        .frame(maxHeight: UIScreen.main.bounds.height / 2.3, alignment: .bottom)
                }
            }
    }
    
    func getRatio(from imageDataString: String) -> Double {
        let components = imageDataString.split(separator: ",")
        guard components.count >= 3, let ratio = Double(components[2]) else {
            return 0.0 // return default value or handle error
        }
        return ratio
    }
}

extension eCardView {
    
    func NoMusicNoGift() -> some View {
        VStack {
            CoverView()
            CollageView()
        }
    }
    
        private func string(for permission: CKShare.ParticipantPermission) -> String {
          switch permission {
          case .unknown:
            return "Unknown"
          case .none:
            return "None"
          case .readOnly:
            return "Read-Only"
          case .readWrite:
            return "Read-Write"
          @unknown default:
            fatalError("A new value added to CKShare.Participant.Permission")
          }
        }

        private func string(for role: CKShare.ParticipantRole) -> String {
          switch role {
          case .owner:
            return "Owner"
          case .privateUser:
            return "Private User"
          case .publicUser:
            return "Public User"
          case .unknown:
            return "Unknown"
          @unknown default:
            fatalError("A new value added to CKShare.Participant.Role")
          }
        }

        private func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
          switch acceptanceStatus {
          case .accepted:
            return "Accepted"
          case .removed:
            return "Removed"
          case .pending:
            return "Invited"
          case .unknown:
            return "Unknown"
          @unknown default:
            fatalError("A new value added to CKShare.Participant.AcceptanceStatus")
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
    
    func saveToCoreDataIfNeeded(coreCard: CoreCard) {
        let context = PersistenceController.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CoreCard> = CoreCard.createFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uniqueName == %@", coreCard.uniqueName)
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {createNewCoreCard(coreCard: coreCard)}
            else {print("CoreCard already exists.")}
        }
        catch {print("Error fetching CoreCard: \(error)")}
    }

    
    func createNewCoreCard(coreCard: CoreCard) {
        let context = PersistenceController.shared.persistentContainer.viewContext
        let newCard = CoreCard(context: context)

        newCard.occassion = coreCard.occassion
        newCard.recipient = coreCard.recipient
        newCard.sender = coreCard.sender
        newCard.an1 = coreCard.an1
        newCard.an2 = coreCard.an2
        newCard.an2URL = coreCard.an2URL
        newCard.an3 = coreCard.an3
        newCard.an4 = coreCard.an4
        newCard.date = coreCard.date
        newCard.font = coreCard.font
        newCard.message = coreCard.message
        newCard.songID = coreCard.songID
        newCard.spotID = coreCard.spotID
        newCard.songName = coreCard.songName
        newCard.spotName = coreCard.spotName
        newCard.songArtistName = coreCard.songArtistName
        newCard.spotArtistName = coreCard.spotArtistName
        newCard.songArtImageData = coreCard.songArtImageData
        newCard.songPreviewURL = coreCard.songPreviewURL
        newCard.songDuration = coreCard.songDuration
        newCard.inclMusic = coreCard.inclMusic
        newCard.spotImageData = coreCard.spotImageData
        newCard.spotSongDuration = coreCard.spotSongDuration
        newCard.spotPreviewURL = coreCard.spotPreviewURL
        newCard.songAlbumName = coreCard.songAlbumName
        newCard.spotAlbumArtist = coreCard.spotAlbumArtist
        newCard.appleAlbumArtist = coreCard.appleAlbumArtist
        newCard.creator = coreCard.creator
        newCard.songAddedUsing = coreCard.songAddedUsing
        newCard.cardName = coreCard.cardName
        newCard.cardType = coreCard.cardType
        newCard.appleSongURL = coreCard.appleSongURL
        newCard.spotSongURL = coreCard.spotSongURL
        newCard.uniqueName = coreCard.uniqueName
        newCard.coverSizeDetails = coreCard.coverSizeDetails
        newCard.unsplashImageURL = coreCard.unsplashImageURL
        newCard.salooUserID = coreCard.salooUserID
        newCard.collage = coreCard.collage

        do {
            try context.save(with: .addCoreCard)
            ErrorMessageViewModel.shared.errorMessage = "Saved to Core Successfully"
        } catch {
            print("Failed to save CoreCard: \(error)")
            ErrorMessageViewModel.shared.errorMessage = error.localizedDescription
        }
    }
    
    
    func saveRecord(with record: CKRecord, for database: CKDatabase) {
        database.save(record) { savedRecord, error in
            if let error = error {print("CloudKit Save Error: \(error.localizedDescription)")}
            else {print("Record Saved Successfully to \(database.databaseScope == .public ? "Public" : "Private") Database!")}
        }
    }
    
    func recordWithAllKeys(record: CKRecord) throws -> CKRecord {
        // Create a new record with the same recordID as the original
        let newRecord = CKRecord(recordType: record.recordType, recordID: record.recordID)
        
        // Iterate over all keys in the original record
        for key in record.allKeys() {
            // Skip the recordChangeTag key
            if key == "recordChangeTag" {
                continue
            }
            
            // Safely get the value for the key
            guard let value = record.object(forKey: key) else {
                throw SaveError.missingValueForKey(key)
            }
            
            // Set the value for the key in the new record
            newRecord.setObject(value, forKey: key)
        }
        
        return newRecord
    }

}

enum SaveError: Error, LocalizedError {
    case missingValueForKey(String)

    var errorDescription: String? {
        switch self {
        case .missingValueForKey(let key):
            return "Record key not found: \(key)"
        }
    }
}
