//
//  SceneDelegate.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/4/23.
//

import Foundation
import UIKit
import CloudKit
import SwiftUI
import os.log


class SceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject {
    var window: UIWindow?
    @State var userID = String()
    var acceptedShare: CKShare?
    let coreCard = CoreCard(context: PersistenceController.shared.persistentContainer.newTaskContext())
    var whichBoxForCKAccept: InOut.SendReceive?
    var gotRecord = false
    var connectToScene = true
    var checkIfRecordAddedToStore = true
    var waitingToAcceptRecord = false
    @ObservedObject var appDelegate = AppDelegate()
    //@ObservedObject var networkMonitor =  NetworkMonitor()
    @ObservedObject var networkMonitor = NetworkMonitor()
    //var hideProgViewOnAcceptShare: Bool = true
    let defaults = UserDefaults.standard
    var counter = 0
    var launchedURL: URL?
    let customLog = OSLog(subsystem: "com.Saloo", category: "Custom Category")
    var spotifyManager: SpotifyManager?
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Handle the URL if one was stored when the app was launched
        if let url = launchedURL, let windowScene = scene as? UIWindowScene {
            print("Set scene in SceneDidBecomeActive")
            self.handleGridofCardsDisplay(windowScene: windowScene)
            launchedURL = nil // Clear the stored URL
        }
    }

    
    func updateMusicSubType() {
        if (defaults.object(forKey: "MusicSubType") as? String) != nil  {
            if (defaults.object(forKey: "MusicSubType") as? String)! == "Apple Music" {appDelegate.musicSub.type = .Apple}
            if (defaults.object(forKey: "MusicSubType") as? String)! == "Spotify" {appDelegate.musicSub.type = .Spotify}
            if (defaults.object(forKey: "MusicSubType") as? String)! == "Neither" {appDelegate.musicSub.type = .Neither}
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("called* openURLContexts")
        guard let url = URLContexts.first?.url else { return }
        if url.absoluteString.contains("spotify_version") {
            print("URL is from Spotify, ignoring")
            return
        }
        let container = CKContainer.default()
        container.fetchShareMetadata(with: url) { metadata, error in
            guard error == nil, let metadata = metadata else {
                print("An error occurred: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            DispatchQueue.main.async {print("called* openURLContexts2");self.processShareMetadata(metadata)}
        }
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("called* willConnectTo")
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidAcceptShare(_:)), name: .didAcceptShare, object: nil)
        
        if connectionOptions.cloudKitShareMetadata != nil {
            //GettingRecord.shared.isLoadingAlert = true
            self.processShareMetadata(connectionOptions.cloudKitShareMetadata!)
        }
        
        print("called* willConnectTo2")
    }
    
    @objc private func handleDidAcceptShare(_ notification: Notification) {
        if let windowScene = window?.windowScene {self.handleGridofCardsDisplay(windowScene: windowScene)}
    }

    private func handleGridofCardsDisplay(windowScene: UIWindowScene) {
        print("called* handleGridofCardsDisplay")
        guard self.gotRecord && self.connectToScene else { return }
        if self.appDelegate.musicSub.type == .Neither {self.updateMusicSubType()}
        AppState.shared.currentScreen = .startMenu
        let contentView = ContentView(hasShownLaunchView: true,cardFromShare: self.coreCard)
                            .onAppear {
                                CardsForDisplay.shared.addCoreCard(card: self.coreCard, box: self.whichBoxForCKAccept!)
                                if let musicSub = (self.defaults.object(forKey: "MusicSubType") as? String) {
                                    if musicSub == "Spotify"{APIManager.shared.initializeSpotifyManager(){}}
                                    if musicSub == "Apple Music"{APIManager.shared.initializeAM(){}}
                                }
                            }
                            //.environmentObject(PersistenceController.shared)
                            .environmentObject(AppState.shared)
                            .environmentObject(CardsForDisplay.shared)
                            .environmentObject(self.appDelegate)
                            .environmentObject(self.networkMonitor)
                            .environmentObject(APIManager.shared)
                            .environmentObject(SpotifyManager.shared)
                            .environmentObject(AlertVars.shared)
                            .environmentObject(GettingRecord.shared)
                            .environmentObject(CollectionManager.shared)
                            .environmentObject(ScreenManager.shared)
                            .environmentObject(CardsForDisplay.shared)
                            .environmentObject(UserSession.shared)
                            .environmentObject(AudioSessionManager.shared)
                            .environmentObject(MusicSubscription.shared)
                            .environmentObject(ShowDetailView.shared)
                            .environmentObject(NetworkMonitor.shared)
                            .environmentObject(CollageImage.shared)
                            .environmentObject(Annotation.shared)
                            .environmentObject(AddMusic.shared)
                            .environmentObject(Occassion.shared)
                            .environmentObject(ChosenCoverImageObject.shared)
                            .environmentObject(ChosenImages.shared)
                            .environmentObject(ChosenSong.shared)
                            .environmentObject(NoteField.shared)
                            .environmentObject(PlayerWrapper.shared)
                            .environmentObject(PersistenceController.shared)

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let initialViewController = UIHostingController(rootView: contentView)
        let navigationController = UINavigationController(rootViewController: initialViewController)
        navigationController.isNavigationBarHidden = true
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        // Customize the transition animation
        let transition = CATransition()
        transition.duration = 5.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        navigationController.view.layer.add(transition, forKey: kCATransition)
        self.gotRecord = false
    }

    /**
     To be able to accept a share, add a CKSharingSupported entry in the Info.plist file and set it to true.
     */
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        print("called* userDidAcceptCloudKitShareWith")
        AppState.shared.currentScreen = .startMenu
        self.processShareMetadata(cloudKitShareMetadata)
        }
    
    
    func updateSharedRecordID(with metadata: CKShare.Metadata) {
        let context = PersistenceController.shared.persistentContainer.newTaskContext()
        let sharedRecordID = metadata.share.recordID.recordName
        // Assuming you have a CoreData entity named SharedRecord
        let sharedRecord = CoreCard(context: context)
        sharedRecord.sharedRecordID = sharedRecordID
        // Save the context
        do {
            try context.save()
            print("Did save sharedRecordID")
            print(sharedRecordID)
        } catch {
            print("Error saving context: \(error)")
        }
    }

    

    func processShareMetadata(_ cloudKitShareMetadata: CKShare.Metadata) {
        print("called* processShareMetadata")
        // Handle the share metadata: fetch the associated record, update your app's state, etc.
        // This code is based on your implementation in userDidAcceptCloudKitShareWith.
        let persistenceController = PersistenceController.shared
        let sharedStore = persistenceController.sharedPersistentStore
        let container = persistenceController.persistentContainer
        container.acceptShareInvitations(from: [cloudKitShareMetadata], into: sharedStore) { [self] (_, error) in
            if let error = error {
                print("\(#function): Failed to accept share invitations: \(error)")
                    // repeat same logic for accept share as participant, and use to open the specified record.
                self.acceptedShare = cloudKitShareMetadata.share; print("Trying to Get Share as Owner...")
                    waitingToAcceptRecord = true
                    Task {
                        await self.getRecordViaQuery(shareMetaData: cloudKitShareMetadata, targetDatabase: PersistenceController.shared.cloudKitContainer.privateCloudDatabase)
                        // Notify observers that a CloudKit share was accepted.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            NotificationCenter.default.post(name: .didAcceptShare, object: nil)
                    }
                }
                } else {
                    self.acceptedShare = cloudKitShareMetadata.share; print("Accepted Share...")
                    waitingToAcceptRecord = true
                    Task {
                        await self.runGetRecord(shareMetaData: cloudKitShareMetadata)
                        
                        ShareMD.shared.metaData = cloudKitShareMetadata
                        print(ShareMD.shared.metaData?.share)
                        //updateSharedRecordID(with: cloudKitShareMetadata)
                        // Notify observers that a CloudKit share was accepted.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            NotificationCenter.default.post(name: .didAcceptShare, object: nil)
                        }
                    }
                }
            }
        print("called* processShareMetadata2")
    }
    
    func runGetRecord(shareMetaData: CKShare.Metadata) async {
        print("called getRecord")
        if self.checkIfRecordAddedToStore {
            print("Running getRecordViaQuery...")
            self.getRecordViaQuery(shareMetaData: shareMetaData, targetDatabase: PersistenceController.shared.cloudKitContainer.sharedCloudDatabase)
        }
    }
    
    
    func getRecordViaQuery(shareMetaData: CKShare.Metadata, targetDatabase: CKDatabase) {
        let gettingRecord = GettingRecord.shared
        gettingRecord.isLoadingAlert = true
        print("called getRecordViaQuery....")
        let pred = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_CoreCard", predicate: pred)
        let op3 = CKQueryOperation(query: query)
        op3.zoneID = shareMetaData.share.recordID.zoneID
        var foundRecord = false
        var delayTask: DispatchWorkItem?
        op3.recordMatchedBlock = {recordID, result in
            foundRecord = true
            delayTask?.cancel() // Cancel showing the alert if we've found the record
            switch result {
            case .success(let record):
                self.checkIfRecordAddedToStore = false
                targetDatabase.fetch(withRecordID: record.recordID){ record, error in
                    self.parseRecord(record: record)
                    print("Got Record...")
                    DispatchQueue.main.async {
                        gettingRecord.isLoadingAlert = false
                        gettingRecord.isShowingActivityIndicator = false
                    }
                }
            case .failure(let error): print("ErrorOpeningShare....\(error)")
            }
        }
        
        op3.queryCompletionBlock = { (cursor, error) in
            print("QueryCompletionBlock")
            if let error = error {print("Error executing CKQueryOperation: \(error)")}
            else {
                if foundRecord {
                    print("CKQueryOperation completed successfully and found records.")
                    DispatchQueue.main.async {
                        gettingRecord.isLoadingAlert = false
                        //gettingRecord.showLoadingRecordAlert  = false
                        gettingRecord.isShowingActivityIndicator = false
                    }
                    self.counter = 0
                } else {
                    print("CKQueryOperation completed successfully but found no records.")
                    // If no records are found, wait for 2 seconds and then retry the operation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        if gettingRecord.willTryAgainLater {return}
                        else {
                            self.getRecordViaQuery(shareMetaData: shareMetaData, targetDatabase: targetDatabase)
                            if self.counter == 0 {
                                gettingRecord.showLoadingRecordAlert  = true
                                AlertVars.shared.alertType = .gettingRecord
                                AlertVars.shared.activateAlert = true
                                print("##")
                                print(AlertVars.shared.alertType)
                                print(AlertVars.shared.activateAlert)
                                gettingRecord.isLoadingAlert = false
                            }
                            print("Counter = \(self.counter)"); self.counter += 1
                            gettingRecord.isLoadingAlert = false
        }}}}}
        targetDatabase.add(op3)
    }

    func parseRecord(record: CKRecord?) {
        print("Parsing Record....")
        DispatchQueue.main.async() {
            self.getCurrentUserID()
            self.coreCard.occassion = record?.object(forKey: "CD_occassion") as! String
            self.coreCard.recipient = record?.object(forKey: "CD_recipient") as! String
            self.coreCard.sender = record?.object(forKey: "CD_sender") as? String
            self.coreCard.an1 = record?.object(forKey: "CD_an1") as! String
            self.coreCard.an2 = record?.object(forKey: "CD_an2") as! String
            self.coreCard.an2URL = record?.object(forKey: "CD_an2URL") as! String
            self.coreCard.an3 = record?.object(forKey: "CD_an3") as! String
            self.coreCard.an4 = record?.object(forKey: "CD_an4") as! String
            self.coreCard.collage = record?.object(forKey: "CD_collage") as? Data
            self.coreCard.coverImage = record?.object(forKey: "CD_coverImage") as? Data
            self.coreCard.date = record?.object(forKey: "CD_date") as! Date
            self.coreCard.font = record?.object(forKey: "CD_font") as! String
            self.coreCard.message = record?.object(forKey: "CD_message") as! String
            self.coreCard.songID = record?.object(forKey: "CD_songID") as? String
            self.coreCard.spotID = record?.object(forKey: "CD_spotID") as? String
            self.coreCard.songName = record?.object(forKey: "CD_songName") as? String
            self.coreCard.spotName = record?.object(forKey: "CD_spotName") as? String
            self.coreCard.songArtistName = record?.object(forKey: "CD_songArtistName") as? String
            self.coreCard.spotArtistName = record?.object(forKey: "CD_spotArtistName") as? String

            self.coreCard.songArtImageData = record?.object(forKey: "CD_songArtImageData") as? Data
            self.coreCard.songPreviewURL = record?.object(forKey: "CD_songPreviewURL") as? String
            self.coreCard.songDuration = record?.object(forKey: "CD_songDuration") as? String
            self.coreCard.inclMusic = record?.object(forKey: "CD_inclMusic") as! Bool
            self.coreCard.spotImageData = record?.object(forKey: "CD_spotImageData") as? Data
            self.coreCard.spotSongDuration = record?.object(forKey: "CD_spotSongDuration") as? String
            self.coreCard.spotPreviewURL = record?.object(forKey: "CD_spotPreviewURL") as? String
            self.coreCard.songAlbumName = record?.object(forKey: "CD_songAlbumName") as? String
            self.coreCard.spotAlbumArtist = record?.object(forKey: "CD_spotAlbumArtist") as? String
            self.coreCard.appleAlbumArtist = record?.object(forKey: "CD_appleAlbumArtist") as? String

            self.coreCard.creator = record?.object(forKey: "CD_creator") as? String
            self.coreCard.songAddedUsing = record?.object(forKey: "CD_songAddedUsing") as? String
            self.coreCard.cardName = record?.object(forKey: "CD_cardName") as! String
            self.coreCard.cardName = record?.object(forKey: "CD_cardName") as! String
            self.coreCard.cardType = record?.object(forKey: "CD_cardType") as! String
            self.coreCard.appleSongURL = record?.object(forKey: "CD_appleSongURL") as! String
            self.coreCard.spotSongURL = record?.object(forKey: "CD_spotSongURL") as! String
            self.appDelegate.chosenGridCard = self.coreCard
            self.determineWhichBox {}
            self.gotRecord = true
            self.checkIfRecordAddedToStore = true
            print("getRecord complete...")
            // Try to get the window scene from the shared application instance.
             if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                 print("Trying to handle Display after parseRecord...")
                 self.handleGridofCardsDisplay(windowScene: windowScene)
             }
        }
    }
    
    func determineWhichBox(completion: @escaping () -> Void) {
        let controller = PersistenceController.shared
        let ckContainer = PersistenceController.shared.cloudKitContainer
        ckContainer.fetchUserRecordID { ckRecordID, error in
            if self.coreCard.creator == (ckRecordID?.recordName)! {
                print("Creator = recordname")
                self.whichBoxForCKAccept = .outbox
                completion()
            }
            else {
                print("Creator != recordname")
                self.whichBoxForCKAccept = .inbox
                completion()
            }
        }
        
    }
    
    func getCurrentUserID() {
        PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
            self.userID = (ckRecordID?.recordName)!
        }
    }
    

}

extension Notification.Name {
    static let didAcceptShare = Notification.Name("didAcceptShare")
}
