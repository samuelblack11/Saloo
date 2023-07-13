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

    //@State var player: AVPlayer?
    @State var selectedPreviewURL: String?
    @State var eCardType: eCardType = .musicNoGift
    @State var cardType: String
    @State var coreCard: CoreCard?
    @State var accessedViaGrid = true
    @State var fromFinalize = false
    //@State private var deferToPreview: Bool?
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
    
    @State private var hasShownLaunchView: Bool = true
    let screenPadding: CGFloat = 5
    var body: some View {
        ZStack {
            if cardType == "musicNoGift" {MusicNoGiftView.modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))}
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
                .onAppear{print("MusicNoGiftView Appeared...")}
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
    
    
    
    func annotationView() -> some View {
        return
        VStack {
            Text(text1)
                .font(.system(size: 8))
            HStack(spacing:0){
                Link(text2, destination: text2URL)
                    .font(.system(size: 8))
                HStack(spacing: 0) {
                    Text(text3)
                        .font(.system(size: 7))
                    Link(text4, destination: URL(string: "https://unsplash.com")!)
                        .font(.system(size: 8))
                }
            }
        }
    }
    
    
    func CoverView() -> some View {
        VStack {
            AsyncImage(url: URL(string: unsplashImageURL!)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            annotationView()
        }
    }

    func CoverViewWide1() -> some View {
        VStack {
            AsyncImage(url: URL(string: unsplashImageURL!)) { image in
                image.resizable()
                    .interpolation(.none)
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: UIScreen.main.bounds.width/1.05, height: UIScreen.main.bounds.height / 4.7)
            annotationView()
        }
    }

    func CoverViewWide2() -> some View {
        VStack {
            AsyncImage(url: URL(string: unsplashImageURL!)) { image in
                image.resizable()
                    .interpolation(.none)
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: UIScreen.main.bounds.width/1.05, height: UIScreen.main.bounds.height / 3.6)
            annotationView()
        }
    }


    func CoverViewTall() -> some View {
        VStack {
            AsyncImage(url: URL(string: unsplashImageURL!)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: UIScreen.main.bounds.height / 2.2, maxHeight: UIScreen.main.bounds.height / 2.3)
            annotationView()
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
            if (deferToPreview == true || spotName == "LookupFailed"  || songName == "LookupFailed" || appDelegate.musicSub.type == .Neither) {
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
                AMPlayerView(songID: songID, songName: songName, songArtistName: songArtistName, spotName: spotName, spotArtistName: spotArtistName, songAlbumName: songAlbumName, songArtImageData: songArtImageData, songDuration: songDuration, songPreviewURL: songPreviewURL, confirmButton: false, fromFinalize: fromFinalize, coreCard: coreCard, appleAlbumArtist: appleAlbumArtist, spotAlbumArtist: spotAlbumArtist, chosenCard: $chosenCard, deferToPreview: $deferToPreview, showAPV: $showAPV, isLoading: $isLoading,songURL: appleSongURL)
                        .frame(maxHeight: UIScreen.main.bounds.height / 2.3, alignment: .bottom)
                }
            else if (appDelegate.musicSub.type == .Spotify) { // && (spotName != "LookupFailed")
                SpotPlayerView(songID: spotID, songName: songName, songArtistName: songArtistName, spotName: spotName, spotArtistName: spotArtistName, songAlbumName: songAlbumName, songArtImageData: spotImageData, songDuration: spotSongDuration, songPreviewURL: spotPreviewURL, appleAlbumArtist: appleAlbumArtist, spotAlbumArtist: spotAlbumArtist, confirmButton: false, songURL: spotSongURL, accessedViaGrid: accessedViaGrid, coreCard: coreCard, chosenCard: $chosenCard, deferToPreview: $deferToPreview, showSPV: $showSPV, isLoading: $isLoading, fromFinalize: fromFinalize)
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
}
