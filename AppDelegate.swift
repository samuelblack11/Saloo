
//
//  AppDelegate.swift
//  GreetMe-2
//
//  Created by Sam Black on 9/1/22.
//
import Foundation
import SwiftUI
import CloudKit
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    @State var acceptedShare: CKShare?
    @State var coreCard: CoreCard?
    let coreCardB = CoreCard(context: PersistenceController.shared.persistentContainer.newTaskContext())
    @State var musicSub = MusicSubscription()
    @Published var deferToPreview = false
    @State var startMenuAppeared = false
    @State var gotRecord = false
    @Published var showGrid = false
    @Published var chosenGridCard: CoreCard? = nil
    @Published var showProgViewOnAcceptShare = false
    @Published var chosenGridCardType: String?
    var songFilterForSearch = ["(live)","[live]","live at","live in","live from", "(mixed)", "[mixed]"]
    var songFilterForMatch = ["(live)","[live]","live at","live in","live from", "(mixed)", "[mixed]", "- single","(deluxe)","(deluxe edition)"]
    var waitingToAcceptRecord = false
    var counter = 0
    var checkIfRecordAddedToStore = true
    @State var userID = String()
    var whichBoxForCKAccept: InOut.SendReceive?

    let appColor = Color("SalooTheme")
    @Published var isLaunchingFromClosed = true
    @Published var isPlayerCreated = false
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("AppDelegate Open with Options being called....")
        let isOpened = openMyApp(from: url)
        return isOpened
    }
    
    //func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
     //   print("didFinishLaunchingWithOptions")
    //    return true
   // }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           // Check if the app is launching from a terminated state
           if let launchOptions = launchOptions, launchOptions[UIApplication.LaunchOptionsKey.annotation] == nil {
               isLaunchingFromClosed = true
           } else {
               isLaunchingFromClosed = false
           }
           
           return true
       }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession:   UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        print("connecting scene session....")
        return configuration
    }
    
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        
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
                    // Notify observers that a CloudKit share was accepted.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        NotificationCenter.default.post(name: .didAcceptShare, object: nil)
                    }
                }
            }
        }
    }
    
    func openMyApp(from url: URL) -> Bool {
        let scheme = "saloo" // Replace this with your app's custom URL scheme
        print("URL being opened....\(url)")
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
            self.coreCardB.occassion = record?.object(forKey: "CD_occassion") as! String
            self.coreCardB.recipient = record?.object(forKey: "CD_recipient") as! String
            self.coreCardB.sender = record?.object(forKey: "CD_sender") as? String
            self.coreCardB.an1 = record?.object(forKey: "CD_an1") as! String
            self.coreCardB.an2 = record?.object(forKey: "CD_an2") as! String
            self.coreCardB.an2URL = record?.object(forKey: "CD_an2URL") as! String
            self.coreCardB.an3 = record?.object(forKey: "CD_an3") as! String
            self.coreCardB.an4 = record?.object(forKey: "CD_an4") as! String
            self.coreCardB.collage = record?.object(forKey: "CD_collage") as? Data
            self.coreCardB.coverImage = record?.object(forKey: "CD_coverImage") as? Data
            self.coreCardB.date = record?.object(forKey: "CD_date") as! Date
            self.coreCardB.font = record?.object(forKey: "CD_font") as! String
            self.coreCardB.message = record?.object(forKey: "CD_message") as! String
            self.coreCardB.songID = record?.object(forKey: "CD_songID") as? String
            self.coreCardB.spotID = record?.object(forKey: "CD_spotID") as? String
            self.coreCardB.songName = record?.object(forKey: "CD_songName") as? String
            self.coreCardB.songArtistName = record?.object(forKey: "CD_songArtistName") as? String
            self.coreCardB.songArtImageData = record?.object(forKey: "CD_songArtImageData") as? Data
            self.coreCardB.songPreviewURL = record?.object(forKey: "CD_songPreviewURL") as? String
            self.coreCardB.songDuration = record?.object(forKey: "CD_songDuration") as? String
            self.coreCardB.inclMusic = record?.object(forKey: "CD_inclMusic") as! Bool
            self.coreCardB.spotImageData = record?.object(forKey: "CD_spotImageData") as? Data
            self.coreCardB.spotSongDuration = record?.object(forKey: "CD_spotSongDuration") as? String
            self.coreCardB.spotPreviewURL = record?.object(forKey: "CD_spotPreviewURL") as? String
            self.coreCardB.creator = record?.object(forKey: "CD_creator") as? String
            self.coreCardB.songAddedUsing = record?.object(forKey: "CD_songAddedUsing") as? String
            self.coreCardB.cardName = record?.object(forKey: "CD_cardName") as! String
            self.coreCardB.cardName = record?.object(forKey: "CD_cardName") as! String
            self.coreCardB.cardType = record?.object(forKey: "CD_cardType") as! String
            self.chosenGridCard = self.coreCardB
            self.determineWhichBox {}
            self.gotRecord = true
            print("getRecord complete...")
        }
    }
    
    func determineWhichBox(completion: @escaping () -> Void) {
        let controller = PersistenceController.shared
        let ckContainer = PersistenceController.shared.cloudKitContainer
        ckContainer.fetchUserRecordID { ckRecordID, error in
            if self.coreCardB.creator == (ckRecordID?.recordName)! {
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
    
    func runGetRecord(shareMetaData: CKShare.Metadata) async {
        print("called getRecord")
        if self.checkIfRecordAddedToStore {
            self.getRecordViaQuery(shareMetaData: shareMetaData, targetDatabase: PersistenceController.shared.cloudKitContainer.sharedCloudDatabase)
        }
    }
    
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
