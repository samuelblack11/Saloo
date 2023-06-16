import Foundation
import SwiftUI
import CoreData
import CloudKit
import AVFoundation
import AVFAudio
struct eCardView: View {
    
    @State var eCardText: String
    @State var font: String
    @State var coverImage: Data
    @State var collageImage: Data
    //@State var chosenCollageStyle: Int
    //@State var collage1: Data
    //@State var collage2: Data?
    //@State var collage3: Data?
    //@State var collage4: Data?
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

    //@State var player: AVPlayer?
    @State var selectedPreviewURL: String?
    @State var eCardType: eCardType = .musicNoGift
    @State var cardType: String
    @State var associatedRecord: CKRecord?
    @State var coreCard: CoreCard?
    @State var accessedViaGrid = true
    @State var fromFinalize = false
    //@State private var deferToPreview: Bool?
    @Binding var chosenCard: CoreCard?
    @State var deferToPreview = false
    @State private var showAPV = true
    @State private var showSPV = true
    @State private var isLoading = false
    @State private var disableTextField = false
    @ObservedObject var gettingRecord = GettingRecord.shared
    @EnvironmentObject var spotifyManager: SpotifyManager
    @ObservedObject var alertVars = AlertVars.shared
    @State var appleSongURL: String?
    @State var spotSongURL: String?
    var body: some View {
        ZStack {
            if cardType == "musicNoGift" {MusicNoGiftView.modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))}
            else{
                if fromFinalize == false {
                    NoMusicNoGiftView
                        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
                        .navigationBarItems(leading:Button {chosenCard = nil
                        } label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
                }
                else {NoMusicNoGiftView.modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))}
            }
            LoadingOverlay()
        }
    }
    
    
    
    var MusicNoGiftView: some View {
        return VStack {
            if getCoverSize().1 < 1.3 {
                HStack {
                    VStack {CoverViewTall(); Spacer(); CollageAndAnnotationView()}
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
                    HStack {CollageAndAnnotationView(); MusicView}
                }
                .onAppear{print("MusicNoGiftView Appeared...")}
            }
        }
    }
    
    
    var NoMusicNoGiftView: some View {
        return GeometryReader { geometry in
            VStack(alignment: .center) {
                if getCoverSize().1 < 1.3 {
                    let height = geometry.size.height / 2.2
                    HStack{CoverViewTall();CollageAndAnnotationView()}.frame(height: height)
                    NoteViewSquare()
                }
                else {
                    VStack(alignment: .center) {
                        CoverViewWide2()
                        Spacer()
                        HStack{CollageAndAnnotationView();NoteViewSquare()}
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    func CoverView() -> some View {
        return Image(uiImage: UIImage(data: coverImage)!)
                //.interpolation(.none).resizable().scaledToFit()
    }
    
    func CoverViewWide1() -> some View {
        return Image(uiImage: UIImage(data: coverImage)!)
                .interpolation(.none).resizable()
                .frame(width: UIScreen.main.bounds.width/1.05, height: UIScreen.main.bounds.height / 4.2, alignment: .center)
                .scaledToFill()
    }

    func CoverViewWide2() -> some View {
        return Image(uiImage: UIImage(data: coverImage)!)
                .interpolation(.none).resizable()
                .frame(width: UIScreen.main.bounds.width/1.05, height: UIScreen.main.bounds.height / 3.3, alignment: .center)
                .scaledToFill()
    }
    
    
    func CoverViewTall() -> some View {
        return Image(uiImage: UIImage(data: coverImage)!)
            //.interpolation(.none).resizable().scaledToFit()
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: UIScreen.main.bounds.height / 2.2, maxHeight: UIScreen.main.bounds.height / 2.3)
    }
    
    func NoteView() -> some View {
        return
        Text(eCardText)
            .font(Font.custom(font, size: 500)).minimumScaleFactor(0.01)
            .frame(width: UIScreen.screenWidth/2.2, height: UIScreen.screenHeight/4.0)
    }
    
    func NoteViewSquare() -> some View {
        return
        Text(eCardText)
            .font(Font.custom(font, size: 500)).minimumScaleFactor(0.01)
            .frame(maxWidth: UIScreen.main.bounds.height / 2.2, maxHeight: UIScreen.main.bounds.height / 2.3)
            //.frame(width: UIScreen.screenWidth/2.2, height: UIScreen.screenHeight/2.3)
    }
    
    func CollageAndAnnotationView() -> some View {
        return VStack(spacing: 5) {
            Image(uiImage: UIImage(data: collageImage)!)
                .interpolation(.high)
                .resizable()
                .scaledToFit()
            Text(text1)
                .font(.system(size: 10))
            HStack(spacing:0){
                Link(text2, destination: text2URL)
                    .font(.system(size: 10))
                HStack(spacing: 0) {
                    Text(text3)
                        .font(.system(size: 8))
                    Link(text4, destination: URL(string: "https://unsplash.com")!)
                        .font(.system(size: 10))
                }
            }
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
                AMPlayerView(songID: songID, songName: songName, songArtistName: songArtistName, spotName: spotName, spotArtistName: spotArtistName, songAlbumName: songAlbumName, songArtImageData: songArtImageData, songDuration: songDuration, songPreviewURL: songPreviewURL, confirmButton: false, fromFinalize: fromFinalize, coreCard: coreCard, appleAlbumArtist: appleAlbumArtist, spotAlbumArtist: spotAlbumArtist, chosenCard: $chosenCard, deferToPreview: $deferToPreview, showAPV: $showAPV, isLoading: $isLoading)
                        .frame(maxHeight: UIScreen.main.bounds.height / 2.3, alignment: .bottom)

                }
            else if (appDelegate.musicSub.type == .Spotify) { // && (spotName != "LookupFailed")
                SpotPlayerView(songID: spotID, songName: songName, songArtistName: songArtistName, spotName: spotName, spotArtistName: spotArtistName, songAlbumName: songAlbumName, songArtImageData: spotImageData, songDuration: spotSongDuration, songPreviewURL: spotPreviewURL, appleAlbumArtist: appleAlbumArtist, spotAlbumArtist: spotAlbumArtist, confirmButton: false, accessedViaGrid: accessedViaGrid, coreCard: coreCard, chosenCard: $chosenCard, deferToPreview: $deferToPreview, showSPV: $showSPV, isLoading: $isLoading)
                    .frame(maxHeight: UIScreen.main.bounds.height / 2.3, alignment: .bottom)
                }
            }
    }
    
    
    func getCoverSize() -> (CGSize, Double) {
        var size = CGSize()
        var widthToHeightRatio = Double()
        if let image = UIImage(data: coverImage) {
            let imageSize = image.size
            size = imageSize
        }
        print("Image Size....")
        widthToHeightRatio = size.width/size.height
        print(size)
        print(widthToHeightRatio)
        return (size, widthToHeightRatio)
    }
    
    func scaledFrame(for size: CGSize, scalingFactor: CGFloat) -> CGRect {
        let maxWidth = size.width * scalingFactor
        let maxHeight = size.height * scalingFactor
        let aspectRatio = size.width / size.height

        var width = maxWidth
        var height = maxHeight

        if aspectRatio > 1 {
            // landscape image
            height = maxWidth / aspectRatio
        } else {
            // portrait image
            width = maxHeight * aspectRatio
        }

        let x = (maxWidth - width) / 2
        let y = (maxHeight - height) / 2

        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}

















extension eCardView {
    
    func NoMusicNoGift() -> some View {
        VStack {
            CoverView()
            CollageAndAnnotationView()
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
