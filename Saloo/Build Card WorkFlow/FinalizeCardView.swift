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
    @State private var enableShare = false
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
    @State var emptyCoreCard: CoreCard?
    var config = SPTConfiguration(clientID: "d15f76f932ce4a7c94c2ecb0dfb69f4b", redirectURL: URL(string: "saloo://")!)
    var appRemote2: SPTAppRemote?
    @State var emptyCard: CoreCard? = CoreCard()
    @State private var sharingController: UICloudSharingController?
    @StateObject var wrapper = CoreCardWrapper()
    
    
    
    
    
    
    
    //let emptyCard = CoreCard(id: "", cardName: "", occassion: "", recipient: "", sender: "", associatedRecord: CKRecord(recordType: ""), an1: "", an2: "", an2URL: "", an3: "", an4: "", collage: Data(), coverImage: Data(), date: Date(), font: "", message: "", uniqueName: "", songID: "", spotID: "", spotName: "", spotArtistName: "", songName: "", songArtistName: "", songArtImageData: Data(), songPreviewURL: "", songDuration: Int(), inclMusic: Bool, spotImageData: Data(), spotSongDuration: Int(), spotPreviewURL: "", creator: "", songAddedUsing: "", collage1: Data(), collage2: Data(), collage3: Data(), collage4: Data(), cardType: "", recordID: "", songAlbumName: "", appleAlbumArtist: "", spotAlbumArtist: "")
    @State private var safeAreaHeight: CGFloat = 0
    
    var defaultCallback: SPTAppRemoteCallback? {
        get {
            return {[self] _, error in
                print("defaultCallBack Running...")
                print("started playing playlist")
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @EnvironmentObject var chosenSong: ChosenSong
    
    var saveButton: some View {
        Button("Save to Drafts") {
            Task {saveCard(noteField: noteField, chosenOccassion: chosenOccassion, an1: annotation.text1, an2: annotation.text2, an2URL: annotation.text2URL.absoluteString, an3: annotation.text3, an4: annotation.text4, chosenObject: chosenObject, collageImage: collageImage, songID: chosenSong.id, spotID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songName: chosenSong.name, songArtistName: chosenSong.artistName, songAlbumName: chosenSong.songAlbumName, songArtImageData: chosenSong.artwork, songPreviewURL: chosenSong.songPreviewURL, songDuration: String(chosenSong.durationInSeconds), inclMusic: addMusic.addMusic, spotImageData: chosenSong.spotImageData, spotSongDuration: String(chosenSong.spotSongDuration), spotPreviewURL: chosenSong.spotPreviewURL, songAddedUsing: chosenSong.songAddedUsing, cardType: cardType, appleAlbumArtist: chosenSong.appleAlbumArtist,spotAlbumArtist: chosenSong.spotAlbumArtist)}
            showCompleteAlert = true
        }
        .frame(height: UIScreen.screenHeight/20)
        .fullScreenCover(isPresented: $showStartMenu) {OccassionsMenu()}
        .fullScreenCover(isPresented: $showCollageMenu) {CollageStyleMenu()}
        .fullScreenCover(isPresented: $showUCV) {UnsplashCollectionView()}
        //.fullScreenCover(item: $sharingController) { controller in
        //    CloudSharingView(controller: controller)
        // }
        .disabled(saveAndShareIsActive)
        .alert("Save Complete", isPresented: $showCompleteAlert) {
            Button("Ok", role: .cancel) {showCollageBuilder = false; showWriteNote = false; showCollageMenu = false; showUCV = false;showStartMenu = true; let rootViewController = UIApplication.shared.connectedScenes
                    .filter {$0.activationState == .foregroundActive }
                    .map {$0 as? UIWindowScene }
                    .compactMap { $0 }
                    .first?.windows
                    .filter({$0.isKeyWindow }).first?.rootViewController
                rootViewController?.dismiss(animated: true)
            }
        }
    }
    
    var saveAndShareButton: some View {
        Button("Save & Share") {
            enableShare = true
            Task {saveCard(noteField: noteField, chosenOccassion: chosenOccassion, an1: annotation.text1, an2: annotation.text2, an2URL: annotation.text2URL.absoluteString, an3: annotation.text3, an4: annotation.text4, chosenObject: chosenObject, collageImage: collageImage, songID: chosenSong.id, spotID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songName: chosenSong.name, songArtistName: chosenSong.artistName, songAlbumName: chosenSong.songAlbumName, songArtImageData: chosenSong.artwork, songPreviewURL: chosenSong.songPreviewURL, songDuration: String(chosenSong.durationInSeconds), inclMusic: addMusic.addMusic, spotImageData: chosenSong.spotImageData, spotSongDuration: String(chosenSong.spotSongDuration), spotPreviewURL: chosenSong.spotPreviewURL, songAddedUsing: chosenSong.songAddedUsing, cardType: cardType, appleAlbumArtist: chosenSong.appleAlbumArtist,spotAlbumArtist: chosenSong.spotAlbumArtist);
                print("Save & Share CoreCard...")
            }
        }
    }
    
    
    
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0){
                    eCardView(eCardText: noteField.noteText, font: noteField.font, coverImage: chosenObject.coverImage, collageImage: collageImage.collageImage, text1: annotation.text1, text2: annotation.text2, text2URL: annotation.text2URL, text3: annotation.text3, text4: annotation.text4, songID: chosenSong.id, spotID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songName: chosenSong.name, songArtistName: chosenSong.artistName, songArtImageData: chosenSong.artwork, songDuration: chosenSong.durationInSeconds, songPreviewURL: chosenSong.songPreviewURL, inclMusic: addMusic.addMusic, spotImageData: chosenSong.spotImageData, spotSongDuration: chosenSong.spotSongDuration, spotPreviewURL: chosenSong.spotPreviewURL, songAddedUsing: chosenSong.songAddedUsing, appRemote2: appRemote2, cardType: cardType, accessedViaGrid: false, fromFinalize: true, chosenCard: $emptyCard)
                        .frame(maxHeight: geometry.size.height - geometry.safeAreaInsets.bottom) // subtract height of toolbar
                    Spacer()
                    HStack {
                        saveButton
                        Spacer()
                        saveAndShareButton
                    }
                }
                .onAppear {
                    safeAreaHeight = geometry.size.height
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        if addMusic.addMusic == false {
                            Button {if addMusic.addMusic{showMusicSearch = true} else {showWriteNote = true}}label: {Image(systemName: "chevron.left").foregroundColor(.blue)
                                Text("Back")}
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {showStartMenu = true} label: {Image(systemName: "menucard.fill").foregroundColor(.blue)
                            Text("Menu")}
                    }
                }
            }
            .fullScreenCover(isPresented: $shareFromGrid) {GridofCards(cardsForDisplay: CoreCardUtils.loadCoreCards(), whichBoxVal: .draftbox, shouldShareCard: true, cardQueuedForshare: createdCard!)}
            .fullScreenCover(isPresented: $showStartMenu) {StartMenu(appRemote2: appRemote2)}
            .fullScreenCover(isPresented: $showMusicSearch) {MusicSearchView()}
            .fullScreenCover(isPresented: $showWriteNote) {WriteNoteView()}
            .fullScreenCover(isPresented: $showShareSheet, content: {if let share = share {}})
            .fullScreenCover(isPresented: $showActivityController) {ActivityView(activityItems: $activityItemsArray, applicationActivities: nil)}
        }
        .environmentObject(wrapper)
        .onAppear{ if appDelegate.musicSub.type == .Spotify{appRemote2?.playerAPI?.pause()}}
    }
}


extension FinalizeCardView {
    
    private func saveCard(noteField: NoteField, chosenOccassion: Occassion, an1: String, an2: String, an2URL: String, an3: String, an4: String, chosenObject: ChosenCoverImageObject, collageImage: CollageImage, songID: String?, spotID: String?, spotName: String?, spotArtistName: String?, songName: String?, songArtistName: String?, songAlbumName: String?, songArtImageData: Data?, songPreviewURL: String?, songDuration: String?, inclMusic: Bool, spotImageData: Data?, spotSongDuration: String?, spotPreviewURL: String?, songAddedUsing: String?, cardType: String, appleAlbumArtist: String?,spotAlbumArtist: String?) {
        let controller = PersistenceController.shared
        //let taskContext = controller.persistentContainer.newTaskContext()
        let taskContext = controller.persistentContainer.viewContext
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        controller.addCoreCard(noteField: noteField, chosenOccassion: chosenOccassion, an1: an1, an2: an2, an2URL: an2URL, an3: an3, an4: an4, chosenObject: chosenObject, collageImage: collageImage,context: taskContext, songID: songID, spotID: spotID, spotName: spotName, spotArtistName: spotArtistName, songName: songName, songArtistName: songArtistName, songAlbumName: songAlbumName, songArtImageData: songArtImageData, songPreviewURL: songPreviewURL, songDuration: songDuration, inclMusic: inclMusic, spotImageData: spotImageData, spotSongDuration: spotSongDuration, spotPreviewURL: spotPreviewURL, songAddedUsing: songAddedUsing, cardType: cardType, appleAlbumArtist: appleAlbumArtist,spotAlbumArtist: spotAlbumArtist, completion: ({
            
            savedCoreCard in
            enableShare = true
            createdCard = savedCoreCard
            wrapper.coreCard = savedCoreCard
            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            createNewShare(coreCard: savedCoreCard)
            //}
            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {shareFromGrid = true}
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
    
// https://medium.com/swiftui-made-easy/activity-view-controller-in-swiftui-593fddadee79
// https://www.hackingwithswift.com/example-code/uikit/how-to-render-pdfs-using-uigraphicspdfrenderer
// https://stackoverflow.com/questions/1134289/cocoa-core-data-efficient-way-to-count-entities
// https://www.advancedswift.com/resize-uiimage-no-stretching-swift/
// https://www.hackingwithswift.com/articles/103/seven-useful-methods-from-cgrect
// https://stackoverflow.com/questions/57727107/how-to-get-the-iphones-screen-width-in-swiftui
// https://www.hackingwithswift.com/read/33/4/writing-to-icloud-with-cloudkit-ckrecord-and-ckasset
// https://swiftwithmajid.com/2022/03/29/zone-sharing-in-cloudkit/
// https://swiftwithmajid.com/2022/03/29/zone-sharing-in-cloudkit/
// https://www.techotopia.com/index.php/An_Introduction_to_CloudKit_Data_Storage_on_iOS_8#Record_Zones
// https://github.com/apple/sample-cloudkit-sharing
// https://stackoverflow.com/questions/66313845/swiftui-dismiss-all-active-sheet-views
