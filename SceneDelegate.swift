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


class SceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject {
    var window: UIWindow?
    @State var userID = String()
    var acceptedShare: CKShare?
    //taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    let coreCard = CoreCard(context: PersistenceController.shared.persistentContainer.newTaskContext())
    var whichBoxForCKAccept: InOut.SendReceive?
    var gotRecord = false
    var connectToScene = true
    //@StateObject var appDelegate = AppDelegate()
    @ObservedObject var appDelegate = AppDelegate()

    /**
     To be able to accept a share, add a CKSharingSupported entry in the Info.plist file and set it to true.
     */
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let persistenceController = PersistenceController.shared
        let sharedStore = persistenceController.sharedPersistentStore
        let container = persistenceController.persistentContainer
        container.acceptShareInvitations(from: [cloudKitShareMetadata], into: sharedStore) { [self] (_, error) in
            if let error = error {print("\(#function): Failed to accept share invitations: \(error)")}
            else {
                self.acceptedShare = cloudKitShareMetadata.share; print("Accepted Share..."); print(self.acceptedShare as Any)
                getRecordViaQuery(share: cloudKitShareMetadata.share)
            }
        }
    }
    
    func getRecordViaQuery(share: CKShare) {
        let ckContainer = PersistenceController.shared.cloudKitContainer
        let pred = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_CoreCard", predicate: pred)
        let op3 = CKQueryOperation(query: query)
        op3.zoneID = share.recordID.zoneID//.zoneName
        op3.recordMatchedBlock = {recordID, result in
            print("Got Record...")
            ckContainer.sharedCloudDatabase.fetch(withRecordID: recordID){ record, error in
                print("***")
                print(record?.object(forKey: "CD_songArtistName") as! String)
                self.parseRecord(record: record)
            }
        }
        op3.queryResultBlock = {result in
            print("queryResultBlock Called")
            //switch result {//case .success(let win): print("This was a success"); //case .failure(let _): print("This faield")//}
        }
        ckContainer.sharedCloudDatabase.add(op3)
        print("Query Complete...")
    }
    
    func parseRecord(record: CKRecord?) {
        DispatchQueue.main.async() {
            self.coreCard.cardName = record?.object(forKey: "CD_cardName") as! String
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
            if self.coreCard.creator! == self.userID { self.whichBoxForCKAccept = .outbox}
            else {self.whichBoxForCKAccept = .inbox}
            self.gotRecord = true
            print("getRecord complete...")
        }
    }
    
    func getCurrentUserID() {
        PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
            self.userID = (ckRecordID?.recordName)!
        }
        
    }
    
    
    
    func shareStatus(card: CoreCard) -> (Bool, Bool) {
        var isCardShared: Bool?
        var hasAnyShare: Bool?
        isCardShared = (PersistenceController.shared.existingShare(coreCard: card) != nil)
        hasAnyShare = PersistenceController.shared.shareTitles().isEmpty ? false : true
        
        return (isCardShared!, hasAnyShare!)
    }
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let url = URLContexts.first!.url
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        // Create the SwiftUI view that provides the window contents.
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if self.gotRecord && self.connectToScene {
                    let contentView = EnlargeECardView(chosenCard: self.coreCard, share: self.acceptedShare, cardsForDisplay: self.loadCoreCards(), whichBoxVal: self.whichBoxForCKAccept!).environmentObject(self.appDelegate)
                    print("called willConnectTo")
                    let window = UIWindow(windowScene: windowScene)
                    window.rootViewController = UIHostingController(rootView: contentView)
                    self.window = window
                    window.makeKeyAndVisible()
                    self.connectToScene = false
                    self.connectToScene = false
                    //let url = connectionOptions.urlContexts.first?.url
                    //self.scene(scene, openURLContexts: url)
                }
            }
        }
    }
    
    func loadCoreCards() -> [CoreCard] {
        let request = CoreCard.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        var cardsFromCore: [CoreCard] = []
        do {
            cardsFromCore = try PersistenceController.shared.persistentContainer.viewContext.fetch(request)
            print("Got \(cardsFromCore.count) Cards From Core")
        }
        catch {print("Fetch failed")}
        return cardsFromCore
    }
    
}
