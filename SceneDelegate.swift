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

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        print("Opened URL via openURLContexts....")
        if let url = URLContexts.first?.url {
            if let windowScene = scene as? UIWindowScene {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    self.handleGridofCardsDisplay(windowScene: windowScene)
                }
            }
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("Called continue....")
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                // CKShare URL should start with "https://www.icloud.com/share/"
                if url.absoluteString.starts(with: "https://www.icloud.com/share/") {
                    // Process the URL as a CKShare URL.
                    print("Called handleCKShareURL....")
                    handleCKShareURL(url, scene: scene)
                }
            }
        }
    }

    private func handleCKShareURL(_ url: URL, scene: UIScene) {
        // Parse the URL to get the CKRecordID and CKRecordZoneID.
        // Use the IDs to fetch the shared record from CloudKit.
        // Handle the shared record as needed.

        // Here handle your logic when the CKShare URL has been processed
        if let windowScene = scene as? UIWindowScene {
            print("Tried to handle Display...")
            self.handleGridofCardsDisplay(windowScene: windowScene)
        }
    }


    func sceneDidBecomeActive(_ scene: UIScene) {
        print("SceneDidBecomeActive....")
        print(scene.title)
        print(launchedURL)
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
    
    @objc private func handleDidAcceptShare(_ notification: Notification) {
        // Here handle your logic when the CKShare has been accepted
        if let windowScene = window?.windowScene {
            self.handleGridofCardsDisplay(windowScene: windowScene)
        }
    }

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //scene.userActivity?.removeAllSavedStates()
        print("willConnectTo called...")
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidAcceptShare(_:)), name: .didAcceptShare, object: nil)

        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
        // Check if the app was launched with a URL
        if let urlContext = connectionOptions.urlContexts.first {
            print("App launched with URL: \(urlContext.url.absoluteString)")
            // Save the URL to process it later in sceneDidBecomeActive
            self.launchedURL = urlContext.url
        }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        if let urlContext = connectionOptions.urlContexts.first {
            let isOpened = openMyApp(from: urlContext.url)
            if isOpened {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
                    self.handleGridofCardsDisplay(windowScene: windowScene)
                }
            }
        }
        
        if let windowScene = scene as? UIWindowScene {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                self.handleGridofCardsDisplay(windowScene: windowScene)
            }
        }
    }
    
    private func handleGridofCardsDisplay(windowScene: UIWindowScene) {
        if self.gotRecord && self.connectToScene {
            if self.appDelegate.musicSub.type == .Neither{self.updateMusicSubType()}
            let contentView = GridofCards(cardsForDisplay: CoreCardUtils.loadCoreCards(), whichBoxVal: self.whichBoxForCKAccept!, chosenCard: self.coreCard)
                .environmentObject(self.appDelegate)
                .environmentObject(self.networkMonitor)
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            let initialViewController = UIHostingController(rootView: contentView)
            let navigationController = UINavigationController(rootViewController: initialViewController)
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
    }

    /**
     To be able to accept a share, add a CKSharingSupported entry in the Info.plist file and set it to true.
     */
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let persistenceController = PersistenceController.shared
        let sharedStore = persistenceController.sharedPersistentStore
        let container = persistenceController.persistentContainer
        os_log("called userDidAcceptCloudKitShareWith....", log: customLog, type: .info)

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
                        // Notify observers that a CloudKit share was accepted.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            NotificationCenter.default.post(name: .didAcceptShare, object: nil)
                        }
                    }
                }
            }
        }


    
    func runGetRecord(shareMetaData: CKShare.Metadata) async {
        print("called getRecord")
        if self.checkIfRecordAddedToStore {
            self.getRecordViaQuery(shareMetaData: shareMetaData, targetDatabase: PersistenceController.shared.cloudKitContainer.sharedCloudDatabase)
        }
    }
    
    
    func getRecordViaQuery(shareMetaData: CKShare.Metadata, targetDatabase: CKDatabase) {
        print("called getRecordViaQuery....")
        let pred = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_CoreCard", predicate: pred)
        let op3 = CKQueryOperation(query: query)
        op3.zoneID = shareMetaData.share.recordID.zoneID
        var foundRecord = false
        op3.recordMatchedBlock = {recordID, result in
            foundRecord = true
            GettingRecord.shared.showLoadingRecordAlert  = true
            switch result {
            case .success(let record):
                self.checkIfRecordAddedToStore = false
                targetDatabase.fetch(withRecordID: record.recordID){ record, error in
                    self.parseRecord(record: record)
                    print("Got Record...")
                    GettingRecord.shared.isShowingActivityIndicator = false
                }
            case .failure(let error): print("ErrorOpeningShare....\(error)")
            }
        }
        
        op3.queryCompletionBlock = { (cursor, error) in
            //if GettingRecord.shared.didDismissRecordAlert == false {GettingRecord.shared.showLoadingRecordAlert = true}
            print("QueryCompletionBlock")
            if let error = error {print("Error executing CKQueryOperation: \(error)")}
            else {
                if foundRecord {
                    print("CKQueryOperation completed successfully and found records.")
                    GettingRecord.shared.showLoadingRecordAlert  = false
                    GettingRecord.shared.isShowingActivityIndicator = false
                    self.counter = 0
                } else {
                    //GettingRecord.shared.showLoadingRecordAlert  = true
                    if self.counter < 20 {
                        print("CKQueryOperation completed successfully but found no records.")
                        // If no records are found, wait for 2 seconds and then retry the operation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if GettingRecord.shared.willTryAgainLater {return}
                            else {
                                self.getRecordViaQuery(shareMetaData: shareMetaData, targetDatabase: targetDatabase)
                                print("Counter = \(self.counter)"); self.counter += 1
                                if GettingRecord.shared.didDismissRecordAlert == false {GettingRecord.shared.showLoadingRecordAlert = true}
                            }
                        }
                    }
                }
            }
        }

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
            self.coreCard.songArtistName = record?.object(forKey: "CD_songArtistName") as? String
            self.coreCard.songArtImageData = record?.object(forKey: "CD_songArtImageData") as? Data
            self.coreCard.songPreviewURL = record?.object(forKey: "CD_songPreviewURL") as? String
            self.coreCard.songDuration = record?.object(forKey: "CD_songDuration") as? String
            self.coreCard.inclMusic = record?.object(forKey: "CD_inclMusic") as! Bool
            self.coreCard.spotImageData = record?.object(forKey: "CD_spotImageData") as? Data
            self.coreCard.spotSongDuration = record?.object(forKey: "CD_spotSongDuration") as? String
            self.coreCard.spotPreviewURL = record?.object(forKey: "CD_spotPreviewURL") as? String
            self.coreCard.creator = record?.object(forKey: "CD_creator") as? String
            self.coreCard.songAddedUsing = record?.object(forKey: "CD_songAddedUsing") as? String
            self.coreCard.cardName = record?.object(forKey: "CD_cardName") as! String
            self.coreCard.cardName = record?.object(forKey: "CD_cardName") as! String
            self.coreCard.cardType = record?.object(forKey: "CD_cardType") as! String
            self.appDelegate.chosenGridCard = self.coreCard
            self.determineWhichBox {}
            self.gotRecord = true
            print("getRecord complete...")
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
    
    func getCurrentUserID2() {
        PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
            self.userID = (ckRecordID?.recordName)!
        }
    }
    
    

    func openMyApp(from url: URL) -> Bool {
        print("Called OpenMyApp")
        let scheme = "saloo" // Replace this with your app's custom URL scheme
        // Check if the URL contains your app's custom URL scheme
        if url.scheme == scheme {
            // Attempt to open the app
            if let appURL = URL(string: "\(scheme)://") {
                if UIApplication.shared.canOpenURL(appURL) {
                    UIApplication.shared.open(appURL)
                    return true
                }
            }
        }
        // If the URL does not contain your app's custom URL scheme or the app cannot be opened, return false
        return false
    }
}

extension Notification.Name {
    static let didAcceptShare = Notification.Name("didAcceptShare")
}
