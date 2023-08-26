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
import MessageUI


struct FinalizeCardView: View {
    @ObservedObject var alertVars = AlertVars.shared
    @EnvironmentObject var chosenImagesObject: ChosenImages

    @EnvironmentObject var chosenOccassion: Occassion
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    @EnvironmentObject var collageImage: CollageImage
    @EnvironmentObject var noteField: NoteField
    @EnvironmentObject var addMusic: AddMusic
    @EnvironmentObject var annotation: Annotation
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
    @State var share: CKShare?
    @State var cardType: String
    var config = SPTConfiguration(clientID: APIManager.shared.spotClientIdentifier, redirectURL: URL(string: "saloo://")!)
    @State var emptyCard: CoreCard? = CoreCard()
    @State private var enableShare = false
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var spotifyManager: SpotifyManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var cardsForDisplay: CardsForDisplay
    @State private var safeAreaHeight: CGFloat = 0
    let defaults = UserDefaults.standard
    @EnvironmentObject var chosenSong: ChosenSong
    @EnvironmentObject var cardProgress: CardProgress
    @State private var isShowingMessageComposer = false
    @EnvironmentObject var linkURL: LinkURL

    var saveButton: some View {
        Button(action: {
            Task {saveCard(noteField: noteField, chosenOccassion: chosenOccassion, an1: annotation.text1, an2: annotation.text2, an2URL: annotation.text2URL.absoluteString, an3: annotation.text3, an4: annotation.text4, chosenObject: chosenObject, collageImage: collageImage, songID: chosenSong.id, spotID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songName: chosenSong.name, songArtistName: chosenSong.artistName, songAlbumName: chosenSong.songAlbumName, songArtImageData: chosenSong.artwork, songPreviewURL: chosenSong.songPreviewURL, songDuration: String(chosenSong.durationInSeconds), inclMusic: addMusic.addMusic, spotImageData: chosenSong.spotImageData, spotSongDuration: String(chosenSong.spotSongDuration), spotPreviewURL: chosenSong.spotPreviewURL, songAddedUsing: chosenSong.songAddedUsing, cardType: cardType, appleAlbumArtist: chosenSong.appleAlbumArtist,spotAlbumArtist: chosenSong.spotAlbumArtist, salooUserID: (UserDefaults.standard.object(forKey: "SalooUserID") as? String)!, appleSongURL: chosenSong.appleSongURL, spotSongURL: chosenSong.spotSongURL)
                DispatchQueue.main.async{GettingRecord.shared.isLoadingAlert = true}
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    DispatchQueue.main.async{GettingRecord.shared.isLoadingAlert = false}
                    alertVars.alertType = .showCardComplete
                    alertVars.activateAlert = true
                }
            }
        }) {
            Text("Save Card")
                .font(Font.custom("Papyrus", size: 16))
        }
        .frame(height: UIScreen.screenHeight/20)
        .disabled(saveAndShareIsActive)
    }
    
    var saveAndShareButton: some View {
        Button(action: {
            if networkMonitor.isConnected {
                DispatchQueue.main.async{GettingRecord.shared.isLoadingAlert = true}
                enableShare = true
                Task {saveCard(noteField: noteField, chosenOccassion: chosenOccassion, an1: annotation.text1, an2: annotation.text2, an2URL: annotation.text2URL.absoluteString, an3: annotation.text3, an4: annotation.text4, chosenObject: chosenObject, collageImage: collageImage, songID: chosenSong.id, spotID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songName: chosenSong.name, songArtistName: chosenSong.artistName, songAlbumName: chosenSong.songAlbumName, songArtImageData: chosenSong.artwork, songPreviewURL: chosenSong.songPreviewURL, songDuration: String(chosenSong.durationInSeconds), inclMusic: addMusic.addMusic, spotImageData: chosenSong.spotImageData, spotSongDuration: String(chosenSong.spotSongDuration), spotPreviewURL: chosenSong.spotPreviewURL, songAddedUsing: chosenSong.songAddedUsing, cardType: cardType, appleAlbumArtist: chosenSong.appleAlbumArtist,spotAlbumArtist: chosenSong.spotAlbumArtist, salooUserID: (UserDefaults.standard.object(forKey: "SalooUserID") as? String)!, appleSongURL: chosenSong.appleSongURL, spotSongURL: chosenSong.spotSongURL)
                }
            }
            else {
                alertVars.alertType = .showFailedToShare
                alertVars.activateAlert = true
            }
        }) {Text("Save & Share")
                .font(Font.custom("Papyrus", size: 16))
            }
    }
    

    func resetFieldsAndNavigateToStartMenu() {
        noteField.noteText = MaximumText(limit: 225, value:  "Write Your Message Here")
        noteField.recipient = MaximumText(limit: 20, value: "To:")
        noteField.sender = MaximumText(limit: 20, value: "From:")
        noteField.cardName = MaximumText(limit: 20, value: "Name Your Card")
        chosenImagesObject.chosenImageA = nil
        chosenImagesObject.chosenImageB = nil
        chosenImagesObject.chosenImageC = nil
        chosenImagesObject.chosenImageD = nil
        appState.currentScreen = .startMenu
    }

    
    var body: some View {
        NavigationView {
            VStack {
                if addMusic.addMusic{CustomNavigationBar(onBackButtonTap: {cardProgress.currentStep = 3; appState.currentScreen = .buildCard([.musicSearchView])}, titleContent: .text("Finalize Card"), rightButtonAction: resetFieldsAndNavigateToStartMenu)}
                else{CustomNavigationBar(onBackButtonTap: {cardProgress.currentStep = 3; appState.currentScreen = .buildCard([.writeNoteView])}, titleContent: .text("Finalize Card"), rightButtonAction: resetFieldsAndNavigateToStartMenu)}
                ProgressBar().frame(height: 20)
                    .frame(height: 20)
                GeometryReader { geometry in
                    VStack(spacing: 0){
                        eCardView(eCardText: noteField.noteText.value, font: noteField.font, collageImage: collageImage.collageImage, text1: annotation.text1, text2: annotation.text2, text2URL: annotation.text2URL, text3: annotation.text3, text4: annotation.text4, songID: chosenSong.id, spotID: chosenSong.spotID, spotName: chosenSong.spotName, spotArtistName: chosenSong.spotArtistName, songName: chosenSong.name, songArtistName: chosenSong.artistName, songArtImageData: chosenSong.artwork, songDuration: chosenSong.durationInSeconds, songPreviewURL: chosenSong.songPreviewURL, inclMusic: addMusic.addMusic, spotImageData: chosenSong.spotImageData, spotSongDuration: chosenSong.spotSongDuration, spotPreviewURL: chosenSong.spotPreviewURL, songAddedUsing: chosenSong.songAddedUsing, cardType: cardType, accessedViaGrid: false, fromFinalize: true, chosenCard: $emptyCard, appleSongURL: chosenSong.appleSongURL, spotSongURL: chosenSong.spotSongURL, unsplashImageURL: chosenObject.smallImageURLString, coverSizeDetails: chosenObject.coverSizeDetails, coverImageIfPersonal: chosenObject.coverImage)
                            .frame(maxHeight: geometry.size.height - geometry.safeAreaInsets.bottom) // subtract height of toolbar
                        Spacer()
                        HStack {
                            saveButton
                            Spacer()
                            saveAndShareButton
                        }
                    }
                    .onAppear {safeAreaHeight = geometry.size.height}
                }
            }
            .sheet(isPresented: $isShowingMessageComposer) {
                // Your MessageComposer view
                MessageComposerView(linkURL: URL(string: linkURL.linkURL)!, fromFinalize: true)
            }
            .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType, alertDismissAction: {appState.currentScreen = .startMenu}))
        }
    }
}


extension FinalizeCardView {
    
    private func saveCard(noteField: NoteField, chosenOccassion: Occassion, an1: String, an2: String, an2URL: String, an3: String, an4: String, chosenObject: ChosenCoverImageObject, collageImage: CollageImage, songID: String?, spotID: String?, spotName: String?, spotArtistName: String?, songName: String?, songArtistName: String?, songAlbumName: String?, songArtImageData: Data?, songPreviewURL: String?, songDuration: String?, inclMusic: Bool, spotImageData: Data?, spotSongDuration: String?, spotPreviewURL: String?, songAddedUsing: String?, cardType: String, appleAlbumArtist: String?,spotAlbumArtist: String?, salooUserID: String, appleSongURL: String?, spotSongURL: String?) {

        let controller = PersistenceController.shared
        let taskContext = controller.persistentContainer.viewContext
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        controller.addCoreCard(noteField: noteField, chosenOccassion: chosenOccassion, an1: an1, an2: an2, an2URL: an2URL, an3: an3, an4: an4, chosenObject: chosenObject, collageImage: collageImage,context: taskContext, songID: songID, spotID: spotID, spotName: spotName, spotArtistName: spotArtistName, songName: songName, songArtistName: songArtistName, songAlbumName: songAlbumName, songArtImageData: songArtImageData, songPreviewURL: songPreviewURL, songDuration: songDuration, inclMusic: inclMusic, spotImageData: spotImageData, spotSongDuration: spotSongDuration, spotPreviewURL: spotPreviewURL, songAddedUsing: songAddedUsing, cardType: cardType, appleAlbumArtist: appleAlbumArtist, spotAlbumArtist: spotAlbumArtist, salooUserID: salooUserID, appleSongURL: appleSongURL, spotSongURL: spotSongURL, completion: ({
            
            savedCoreCard in
            if enableShare == true {
                self.appState.pauseMusic.toggle()
                createLink(uniqueName: savedCoreCard.uniqueName)
            }
            cardsForDisplay.addCoreCard(card: savedCoreCard, box: .outbox, record: nil)
            noteField.recipient.value = ""
            noteField.sender.value = ""
            noteField.cardName.value = ""
            noteField.noteText.value = "Write Your Message Here"
            chosenImagesObject.chosenImageA = nil
            chosenImagesObject.chosenImageB = nil
            chosenImagesObject.chosenImageC = nil
            chosenImagesObject.chosenImageD = nil

        }))
    }


    func createLink(uniqueName: String) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "saloocardshare.azurewebsites.net"
        
        let queryItems = [
            URLQueryItem(name: "uniqueName", value: uniqueName)
        ]
        
        components.queryItems = queryItems

        if let richLinkURL = components.url {
            linkURL.linkURL = richLinkURL.absoluteString
            sendViaMessages(richLinkURL: richLinkURL)
        } else {
            print("Failed to create rich link URL")
        }
    }



    func sendViaMessages(richLinkURL: URL) {
        if MFMessageComposeViewController.canSendText() && MFMessageComposeViewController.canSendAttachments() {
            let messageComposer = MFMessageComposeViewController()
            messageComposer.body = richLinkURL.absoluteString
            
            // Present the message composer view controller
            DispatchQueue.main.async{GettingRecord.shared.isLoadingAlert = false}
            isShowingMessageComposer = true
        } else {
            print("Cannot send message")
        }
    }
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
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ActivityView>) {}
    }
    

