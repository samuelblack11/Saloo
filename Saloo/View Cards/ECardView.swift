//
//  ECardView.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/10/23.
//

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
    @State var showFCV: Bool = false
    @State var inclMusic: Bool
    @State var spotImageData: Data?
    @State var spotSongDuration: Double?
    @State var spotPreviewURL: String?
    let defaults = UserDefaults.standard
    @EnvironmentObject var appDelegate: AppDelegate
    @State var songAddedUsing: String?
    var appRemote2: SPTAppRemote? = SPTAppRemote(configuration: SPTConfiguration(clientID: "d15f76f932ce4a7c94c2ecb0dfb69f4b", redirectURL: URL(string: "saloo://")!), logLevel: .debug)
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
    var body: some View {
        //if cardType == "musicAndGift" {MusicAndGiftView()}
        //if cardType == "musicNoGift" {MusicNoGiftView()}
        MusicNoGiftView
    }
    
    
    
    var MusicNoGiftView: some View {
        return VStack {
            if getCoverSize().1 < 1.3 {
                HStack {
                    VStack {CoverViewTall(); Spacer(); CollageAndAnnotationView()}
                    VStack {
                        NoteViewSquare()
                        MusicView
                    }
                }
            }
            else {
                VStack {
                    VStack {CoverViewWide(); NoteView()}
                    HStack {CollageAndAnnotationView(); MusicView}
                }
                .onAppear{print("MusicNoGiftView Appeared...")}
            }
        }
    }
    
    func CoverView() -> some View {
        return Image(uiImage: UIImage(data: coverImage)!)
                //.interpolation(.none).resizable().scaledToFit()
    }
    
    func CoverViewWide() -> some View {
        return Image(uiImage: UIImage(data: coverImage)!)
                .interpolation(.none).resizable()
                .frame(maxWidth: UIScreen.main.bounds.width / 1.1, maxHeight: UIScreen.main.bounds.height / 3.7)
                .scaledToFill()
                .onAppear{print("COVER View Wide Appeared...")}
                //.resizable()
                //.aspectRatio(contentMode: .fit)
                
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
            .frame(width: UIScreen.screenWidth/2.2, height: UIScreen.screenHeight/3.8)
    }
    
    
    
    func NoteViewSquare() -> some View {
        return
        Text(eCardText)
            .font(Font.custom(font, size: 500)).minimumScaleFactor(0.01)
            .frame(width: UIScreen.screenWidth/2.2, height: UIScreen.screenHeight/2.3)
    }
    
    func CollageAndAnnotationView() -> some View {
        return VStack {
            Image(uiImage: UIImage(data: collageImage)!)
                .interpolation(.high).resizable().scaledToFit()
                .frame(alignment: .bottom)
                .padding([.bottom, .top], 5)
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing:0){
                    Text(text1)
                        .font(.system(size: 10)).frame(alignment: .center)
                    Link(text2, destination: text2URL)
                        .font(.system(size: 10)).frame(alignment: .center)
                    HStack(spacing: 0) {
                        Text(text3).font(.system(size: 4))
                            .frame(alignment: .center)
                        Link(text4, destination: URL(string: "https://unsplash.com")!)
                            .font(.system(size: 12)).frame(alignment: .center)
                    }
                }
                Spacer()
                VStack(spacing:0) {
                    Text("Greeting Card").font(.system(size: 10))
                    Text("by").font(.system(size: 10))
                    Text("Saloo").font(.system(size: 10)).padding(.bottom,10).padding(.leading, 5)
                }
                Spacer()
            } .frame(alignment: .bottom)
        }
    }
    
    func GiftView() -> some View {
      return Text("{Gift Card Will Go Here}")
            .font(.system(size: 24)).frame(alignment: .center)
            .multilineTextAlignment(.center)
            .frame(maxHeight: .infinity)
    }
    
    var MusicView: some View {
        VStack {
            if (deferToPreview == true || spotName == "LookupFailed"  || songName == "LookupFailed" || appDelegate.musicSub.type == .Neither) {
                if songAddedUsing! == "Spotify"  {
                    SongPreviewPlayer(songID: spotID, songName: spotName, songArtistName: spotArtistName, songArtImageData: spotImageData, songDuration: spotSongDuration, songPreviewURL: spotPreviewURL, confirmButton: false, showFCV: $showFCV, songAddedUsing: songAddedUsing!, chosenCard: $chosenCard)
                        //.onDisappear{if player?.timeControlStatus.rawValue == 2 {player?.pause()}}
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
                else if songAddedUsing! == "Apple"  {
                    SongPreviewPlayer(songID: songID, songName: songName, songArtistName: songArtistName, songArtImageData: songArtImageData, songDuration: songDuration, songPreviewURL: songPreviewURL, confirmButton: false, showFCV: $showFCV, songAddedUsing: songAddedUsing!, chosenCard: $chosenCard)
                        //.onDisappear{if player?.timeControlStatus.rawValue == 2 {player?.pause()}}
                        .frame(maxHeight: .infinity, alignment: .bottom)
                 }
            }
             
            else if (appDelegate.musicSub.type == .Apple)  { // && (songName != "LookupFailed")
                AMPlayerView(songID: songID, songName: songName, songArtistName: songArtistName, spotName: spotName, spotArtistName: spotArtistName, songAlbumName: songAlbumName, songArtImageData: songArtImageData, songDuration: songDuration, songPreviewURL: songPreviewURL, confirmButton: false, showFCV: $showFCV, fromFinalize: fromFinalize, coreCard: coreCard, appleAlbumArtist: appleAlbumArtist, spotAlbumArtist: spotAlbumArtist, chosenCard: $chosenCard, deferToPreview: $deferToPreview)
                        .frame(maxHeight: UIScreen.screenHeight/2.2)
                }
            else if (appDelegate.musicSub.type == .Spotify) { // && (spotName != "LookupFailed")
                SpotPlayerView(songID: spotID, songName: songName, songArtistName: songArtistName, spotName: spotName, spotArtistName: spotArtistName, songAlbumName: songAlbumName, songArtImageData: spotImageData, songDuration: spotSongDuration, songPreviewURL: spotPreviewURL, appleAlbumArtist: appleAlbumArtist, spotAlbumArtist: spotAlbumArtist, confirmButton: false, showFCV: $showFCV, accessedViaGrid: accessedViaGrid, appRemote2: appRemote2, coreCard: coreCard, chosenCard: $chosenCard, deferToPreview: $deferToPreview)
                        .onAppear{appRemote2?.connectionParameters.accessToken = (defaults.object(forKey: "SpotifyAccessToken") as? String)!}
                        .frame(maxHeight: .infinity, alignment: .bottom)
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
    func MusicAndGiftView() -> some View {
        
        HStack {
            VStack {
                CoverView()
                NoteView()
                CollageAndAnnotationView()
            }
            VStack {
                GiftView()
                MusicView
            }
        }
    }
    
    func GiftNoMusicView() -> some View {
        HStack {
            VStack {
                CoverView()
                CollageAndAnnotationView()
            }
            VStack {
                NoteView()
                GiftView()
            }
        }
    }
    
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
