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
    @State var coreCard: CoreCard?
    //var musicSubTimeToAddMusic: Bool = false
    //var musicSubType: MusicSubscriptionOptions = .Neither
    //@EnvironmentObject var appDelegate: AppDelegate
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        // Create the SwiftUI view that provides the window contents.
        //let contentView = MusicSearchView()
        //print("called willConnectTo")

        // Use a UIHostingController as window root view controller.
       // if let windowScene = scene as? UIWindowScene {
       //     let window = UIWindow(windowScene: windowScene)
       //     window.rootViewController = UIHostingController(rootView: contentView)
        //    self.window = window
       //     window.makeKeyAndVisible()
       //}
        
        
        
       // let url = connectionOptions.urlContexts.first?.url
        //self.scene(scene, openURLContexts: url)

      
    }
    
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
                self.fetchShare(cloudKitShareMetadata)
                self.shareStatus(card: self.coreCard!)
                let acceptedECardView = self.window?.rootViewController as! EnlargeECardView()
                EnlargeECardView(chosenCard: coreCard!, share: cloudKitShareMetadata.share, cardsForDisplay: [], whichBoxVal: .inbox)
                
                
                
                
                
                
                // add card to inbox
                // display card via -> Inbox -> EnlargeECardView -> eCardView
                print("------")
                print(cloudKitShareMetadata.rootRecord?.object(forKey: "songName"))
                //EnlargeECardView(chosenCard: , share: , cardsForDisplay: persistenceController., whichBoxVal: .inbox)
                //if owner of card, whichBoxVal: .outbox. Else, .inbox
            }
        }
    }
    
    func shareStatus(card: CoreCard) -> (Bool, Bool) {
        var isCardShared: Bool?
        var hasAnyShare: Bool?
        isCardShared = (PersistenceController.shared.existingShare(coreCard: card) != nil)
        hasAnyShare = PersistenceController.shared.shareTitles().isEmpty ? false : true
        
        return (isCardShared!, hasAnyShare!)
    }
    
    func fetchShare(_ metadata: CKShare.Metadata) {
        //var coreCard = CoreCard?
        let operation = CKFetchRecordsOperation(
            //recordIDs: [metadata.rootRecord?.recordID?.map{String($0)}])
            recordIDs: [metadata.rootRecordID])
        operation.perRecordResultBlock = { record, _, error in
            if error != nil { print(error?.localizedDescription as Any)}

            if record != nil {
                
                
                
                
                DispatchQueue.main.async() {
                    //self.associatedRecord = record
                    //self.cardName = record?.object(forKey: "cardName") as? String
                    coreCard?.cardName = record?.object(forKey: "cardName") as! String
                    self.coreCard?.occassion = record?.object(forKey: "occassion") as! String
                    self.coreCard?.recipient = record?.object(forKey: "recipient") as! String
                    self.coreCard?.sender = record?.object(forKey: "sender") as? String
                    self.coreCard?.an1 = record?.object(forKey: "an1") as! String
                    self.coreCard?.an2 = record?.object(forKey: "an2") as! String
                    self.coreCard?.an2URL = record?.object(forKey: "an2URL") as! String
                    self.coreCard?.an3 = record?.object(forKey: "an3") as! String
                    self.coreCard?.an4 = record?.object(forKey: "an4") as! String
                    self.coreCard?.collage = record?.object(forKey: "collage") as? Data
                    self.coreCard?.coverImage = record?.object(forKey: "coverImage") as? Data
                    self.coreCard?.date = record?.object(forKey: "date") as! Date
                    self.coreCard?.font = record?.object(forKey: "font") as! String
                    self.coreCard?.message = record?.object(forKey: "message") as! String
                    self.coreCard?.songID = record?.object(forKey: "songID") as? String
                    self.coreCard?.spotID = record?.object(forKey: "spotID") as? String
                    self.coreCard?.songName = record?.object(forKey: "songName") as? String
                    self.coreCard?.songArtistName = record?.object(forKey: "songArtistName") as? String
                    self.coreCard?.songArtImageData = record?.object(forKey: "songArtImageData") as? Data
                    self.coreCard?.songPreviewURL = record?.object(forKey: "songPreviewURL") as? String
                    self.coreCard?.songDuration = record?.object(forKey: "songDuration") as? String
                    self.coreCard?.inclMusic = record?.object(forKey: "inclMusic") as! Bool
                    self.coreCard?.spotImageData = record?.object(forKey: "spotImageData") as? Data
                    self.coreCard?.spotSongDuration = record?.object(forKey: "spotSongDuration") as? String
                    self.coreCard?.spotPreviewURL = record?.object(forKey: "spotPreviewURL") as? String
                }
            }
        }

        operation.fetchRecordsCompletionBlock = { _, error in
            if error != nil { print(error?.localizedDescription)}
        }
        CKContainer.default().sharedCloudDatabase.add(operation)
    }

}
