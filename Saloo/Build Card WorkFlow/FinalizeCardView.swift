//
//  FinalizeCardView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//

import Foundation
import SwiftUI
import CoreData
import CloudKit


struct FinalizeCardView: View {
    @ObservedObject var alertVars = AlertVars.shared

    @EnvironmentObject var chosenOccassion: Occassion
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    @EnvironmentObject var collageImage: CollageImage
    @EnvironmentObject var noteField: NoteField
    @EnvironmentObject var addMusic: AddMusic
    @EnvironmentObject var annotation: Annotation
    @EnvironmentObject var spotifyAuth: SpotifyAuth
    @EnvironmentObject var giftCard: GiftCard
    @State var showCloudShareController = false
    @State private var showStartMenu = false
    @State private var showUCV = false
    @State private var showCollageMenu = false
    @State private var showCollageBuilder = false
    @State private var showWriteNote = false
    @State private var showMusicSearch = false
    @EnvironmentObject var appDelegate: AppDelegate
    @State var coreCard: CoreCard!
    @State var savedCoreCardForView: CoreCard!
    @State var cardRecord: CKRecord!
    @State var createdCard: CoreCard?
    @State private var shareFromGrid = false
    //@Binding var cardForExport: Data!
    @State private var showActivityController = false
    @State var activityItemsArray: [Any] = []
    @State var saveAndShareIsActive = false
    @State private var showCompleteAlert = false
    var field1: String!
    var field2: String!
    @State var string1: String!
    @State var string2: String!
    @State private var showShareSheet = false
    @State var share: CKShare?
    @State private var isAddingCard = false
    @State private var isSharing = false
    @State private var isProcessingShare = false
    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    @State var cardType: String
    var config = SPTConfiguration(clientID: APIManager.shared.spotClientIdentifier, redirectURL: URL(string: "saloo://")!)
    @State var emptyCard: CoreCard? = CoreCard()
    @State private var sharingController: UICloudSharingController?
    @State private var enableShare = false
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var spotifyManager: SpotifyManager

    
    
    
    
    
    //let emptyCard = CoreCard(id: "", cardName: "", occassion: "", recipient: "", sender: "", associatedRecord: CKRecord(recordType: ""), an1: "", an2: "", an2URL: "", an3: "", an4: "", collage: Data(), coverImage: Data(), date: Date(), font: "", message: "", uniqueName: "", songID: "", spotID: "", spotName: "", spotArtistName: "", songName: "", songArtistName: "", songArtImageData: Data(), songPreviewURL: "", songDuration: Int(), inclMusic: Bool, spotImageData: Data(), spotSongDuration: Int(), spotPreviewURL: "", creator: "", songAddedUsing: "", collage1: Data(), collage2: Data(), collage3: Data(), collage4: Data(), cardType: "", recordID: "", songAlbumName: "", appleAlbumArtist: "", spotAlbumArtist: "")
    @State private var safeAreaHeight: CGFloat = 0
    

    
    @EnvironmentObject var chosenSong: ChosenSong
    
    var saveButton: some View {
        Button("Save to Drafts") {
            Task {saveCard(noteField: noteField, chosenOccassion: chosenOccassion, an1: annotation.text1, an2: annotation.text2, an2URL: annotation.text2URL.absoluteString, an3: annotation.text3, an4: annotation.text4, chosenObject: chosenObject, collageImage: collageImage, songID: chosenSong.id, spotID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songName: chosenSong.name, songArtistName: chosenSong.artistName, songAlbumName: chosenSong.songAlbumName, songArtImageData: chosenSong.artwork, songPreviewURL: chosenSong.songPreviewURL, songDuration: String(chosenSong.durationInSeconds), inclMusic: addMusic.addMusic, spotImageData: chosenSong.spotImageData, spotSongDuration: String(chosenSong.spotSongDuration), spotPreviewURL: chosenSong.spotPreviewURL, songAddedUsing: chosenSong.songAddedUsing, cardType: cardType, appleAlbumArtist: chosenSong.appleAlbumArtist,spotAlbumArtist: chosenSong.spotAlbumArtist, salooUserID: (UserDefaults.standard.object(forKey: "SalooUserID") as? String)!, appleSongURL: chosenSong.appleSongURL, spotSongURL: chosenSong.spotSongURL)}
            showCompleteAlert = true
            alertVars.alertType = .showCardComplete
            alertVars.activateAlert = true
        }
        .frame(height: UIScreen.screenHeight/20)
        .fullScreenCover(isPresented: $showStartMenu) {OccassionsMenu()}
        .fullScreenCover(isPresented: $showCollageMenu) {CollageStyleMenu()}
        .fullScreenCover(isPresented: $showUCV) {UnsplashCollectionView()}
        //.fullScreenCover(item: $sharingController) { controller in
        //    CloudSharingView(controller: controller)
        // }
        .disabled(saveAndShareIsActive)
    }
    
    var saveAndShareButton: some View {
        Button("Save & Share") {
            if networkMonitor.isConnected {
                enableShare = true
                Task {saveCard(noteField: noteField, chosenOccassion: chosenOccassion, an1: annotation.text1, an2: annotation.text2, an2URL: annotation.text2URL.absoluteString, an3: annotation.text3, an4: annotation.text4, chosenObject: chosenObject, collageImage: collageImage, songID: chosenSong.id, spotID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songName: chosenSong.name, songArtistName: chosenSong.artistName, songAlbumName: chosenSong.songAlbumName, songArtImageData: chosenSong.artwork, songPreviewURL: chosenSong.songPreviewURL, songDuration: String(chosenSong.durationInSeconds), inclMusic: addMusic.addMusic, spotImageData: chosenSong.spotImageData, spotSongDuration: String(chosenSong.spotSongDuration), spotPreviewURL: chosenSong.spotPreviewURL, songAddedUsing: chosenSong.songAddedUsing, cardType: cardType, appleAlbumArtist: chosenSong.appleAlbumArtist,spotAlbumArtist: chosenSong.spotAlbumArtist, salooUserID: (UserDefaults.standard.object(forKey: "SalooUserID") as? String)!, appleSongURL: chosenSong.appleSongURL, spotSongURL: chosenSong.spotSongURL);
                    print("Save & Share CoreCard...")
                }
            }
            else {
                alertVars.alertType = .showFailedToShare
                alertVars.activateAlert = true
            }
            
        }
    }
    
    
    
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0){
                    eCardView(eCardText: noteField.noteText.value, font: noteField.font, coverImage: chosenObject.coverImage, collageImage: collageImage.collageImage, text1: annotation.text1, text2: annotation.text2, text2URL: annotation.text2URL, text3: annotation.text3, text4: annotation.text4, songID: chosenSong.id, spotID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songName: chosenSong.name, songArtistName: chosenSong.artistName, songArtImageData: chosenSong.artwork, songDuration: chosenSong.durationInSeconds, songPreviewURL: chosenSong.songPreviewURL, inclMusic: addMusic.addMusic, spotImageData: chosenSong.spotImageData, spotSongDuration: chosenSong.spotSongDuration, spotPreviewURL: chosenSong.spotPreviewURL, songAddedUsing: chosenSong.songAddedUsing, cardType: cardType, accessedViaGrid: false, fromFinalize: true, chosenCard: $emptyCard, appleSongURL: chosenSong.appleSongURL, spotSongURL: chosenSong.spotSongURL)
                        .frame(maxHeight: geometry.size.height - geometry.safeAreaInsets.bottom) // subtract height of toolbar
                    Spacer()
                    HStack {
                        saveButton
                        Spacer()
                        saveAndShareButton
                    }
                }
                .onAppear {safeAreaHeight = geometry.size.height}
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        if addMusic.addMusic == false {
                            Button {if addMusic.addMusic{showMusicSearch = true} else {showWriteNote = true}}label: {Image(systemName: "chevron.left").foregroundColor(.blue)
                                Text("Back")}
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {returnToMenu()} label: {Image(systemName: "menucard.fill").foregroundColor(.blue)
                            Text("Menu")}
                    }
                }
            }
            .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType, alertDismissAction: {returnToMenu()}))
            .fullScreenCover(isPresented: $showStartMenu) {StartMenu()}
            .fullScreenCover(isPresented: $showMusicSearch) {MusicSearchView()}
            .fullScreenCover(isPresented: $showWriteNote) {WriteNoteView()}
            .fullScreenCover(isPresented: $showShareSheet, content: {if let share = share {}})
            .fullScreenCover(isPresented: $showActivityController) {ActivityView(activityItems: $activityItemsArray, applicationActivities: nil)}
        }
        .onAppear{ if appDelegate.musicSub.type == .Spotify{spotifyManager.appRemote?.playerAPI?.pause()}}
    }
}


extension FinalizeCardView {
    
    func returnToMenu() {
        showCollageBuilder = false; showWriteNote = false; showCollageMenu = false; showUCV = false;showStartMenu = true; let rootViewController = UIApplication.shared.connectedScenes
                            .filter {$0.activationState == .foregroundActive }
                            .map {$0 as? UIWindowScene }
                            .compactMap { $0 }
                            .first?.windows
                            .filter({$0.isKeyWindow }).first?.rootViewController
                        rootViewController?.dismiss(animated: true)
    }
    
    private func saveCard(noteField: NoteField, chosenOccassion: Occassion, an1: String, an2: String, an2URL: String, an3: String, an4: String, chosenObject: ChosenCoverImageObject, collageImage: CollageImage, songID: String?, spotID: String?, spotName: String?, spotArtistName: String?, songName: String?, songArtistName: String?, songAlbumName: String?, songArtImageData: Data?, songPreviewURL: String?, songDuration: String?, inclMusic: Bool, spotImageData: Data?, spotSongDuration: String?, spotPreviewURL: String?, songAddedUsing: String?, cardType: String, appleAlbumArtist: String?,spotAlbumArtist: String?, salooUserID: String, appleSongURL: String?, spotSongURL: String?) {
        let controller = PersistenceController.shared
        //let taskContext = controller.persistentContainer.newTaskContext()
        let taskContext = controller.persistentContainer.viewContext
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        controller.addCoreCard(noteField: noteField, chosenOccassion: chosenOccassion, an1: an1, an2: an2, an2URL: an2URL, an3: an3, an4: an4, chosenObject: chosenObject, collageImage: collageImage,context: taskContext, songID: songID, spotID: spotID, spotName: spotName, spotArtistName: spotArtistName, songName: songName, songArtistName: songArtistName, songAlbumName: songAlbumName, songArtImageData: songArtImageData, songPreviewURL: songPreviewURL, songDuration: songDuration, inclMusic: inclMusic, spotImageData: spotImageData, spotSongDuration: spotSongDuration, spotPreviewURL: spotPreviewURL, songAddedUsing: songAddedUsing, cardType: cardType, appleAlbumArtist: appleAlbumArtist,spotAlbumArtist: spotAlbumArtist, salooUserID: salooUserID, appleSongURL: appleSongURL, spotSongURL: spotSongURL, completion: ({
            
            savedCoreCard in
            if enableShare == true {
                //DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                createNewShare(coreCard: savedCoreCard)
                //}
            }
            //else {PersistenceController.shared.createCKShare(unsharedCoreCard: savedCoreCard, persistenceController: PersistenceController.shared)}
            //else {print("Do Not Share card right now")}
        }))
            
    }
    
    private func createNewShare(coreCard: CoreCard) {PersistenceController.shared.presentCloudSharingController(coreCard: coreCard)}

}


extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
    
    struct ActivityView: UIViewControllerRepresentable {
       @Binding var activityItems: [Any]
       let applicationActivities: [UIActivity]?
       func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
          UIActivityViewController(activityItems: activityItems,
                                applicationActivities: applicationActivities)
       }
       func updateUIViewController(_ uiViewController: UIActivityViewController,
                                   context: UIViewControllerRepresentableContext<ActivityView>) {}
       }
    

